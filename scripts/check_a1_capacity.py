#!/usr/bin/env python3
"""
Check if VM.Standard.A1.Flex is available in any AD of the OCI home region.
If it is, publish a notification to an OCI Notifications topic (and optionally
send email via Gmail SMTP if credentials are provided).

Can authenticate with either:
  - ~/.oci/config (default, for local runs)
  - Instance Principal (when running inside an OCI compute instance)

Usage:
    export NOTIFICATION_EMAIL=rahulrawat.rrc@gmail.com
    python3 scripts/check_a1_capacity.py

Requirements:
    pip install oci
"""

import os
import smtplib
import ssl
import urllib.request
from email.mime.text import MIMEText

import oci

SHAPE = "VM.Standard.A1.Flex"
PROJECT_NAME = os.environ.get("PROJECT_NAME", "oracle-always-free")
TOPIC_NAME = f"{PROJECT_NAME}-capacity-alerts"
RECIPIENT = os.environ.get("NOTIFICATION_EMAIL", "rahulrawat.rrc@gmail.com")

GMAIL_USER = os.environ.get("GMAIL_USER")
GMAIL_APP_PASSWORD = os.environ.get("GMAIL_APP_PASSWORD")

USE_INSTANCE_PRINCIPAL = os.environ.get("USE_INSTANCE_PRINCIPAL", "false").lower() == "true"


def get_region_from_metadata():
    try:
        req = urllib.request.Request(
            "http://169.254.169.254/opc/v1/instance/region",
            headers={"Authorization": "Bearer Oracle"},
        )
        with urllib.request.urlopen(req, timeout=2) as response:
            return response.read().decode("utf-8")
    except Exception:
        return None


def get_config_and_signer():
    if USE_INSTANCE_PRINCIPAL:
        region = os.environ.get("OCI_REGION") or get_region_from_metadata()
        if not region:
            raise RuntimeError(
                "OCI_REGION environment variable is required when using Instance Principal"
            )
        config = {"region": region}
        signer = oci.auth.signers.InstancePrincipalsSecurityTokenSigner()
        return config, signer

    config = oci.config.from_file()
    return config, None


def get_compartment_id(config):
    return os.environ.get("OCI_COMPARTMENT_OCID") or config.get("tenancy")


def check_capacity(compute_client, identity_client, compartment_id):
    ads = identity_client.list_availability_domains(
        compartment_id=compartment_id
    ).data

    available_ads = []
    for ad in ads:
        details = oci.core.models.CreateComputeCapacityReportDetails(
            availability_domain=ad.name,
            shape_availabilities=[
                oci.core.models.CreateCapacityReportShapeAvailabilityDetails(
                    shape_name=SHAPE,
                    instance_count=1,
                )
            ],
        )

        report = compute_client.create_compute_capacity_report(
            create_compute_capacity_report_details=details
        ).data

        status = report.shape_availabilities[0].availability_status
        print(f"  {ad.name}: {status}")

        if status == "AVAILABLE":
            available_ads.append(ad.name)

    return available_ads


def send_ons_notification(config, signer, compartment_id, message):
    control_client = oci.ons.NotificationControlPlaneClient(config, signer=signer)
    data_client = oci.ons.NotificationDataPlaneClient(config, signer=signer)

    topics = control_client.list_topics(
        compartment_id=compartment_id, name=TOPIC_NAME
    ).data

    if topics:
        topic = topics[0]
        print(f"Using existing topic: {topic.topic_id}")
    elif not USE_INSTANCE_PRINCIPAL:
        topic = control_client.create_topic(
            create_topic_details=oci.ons.models.CreateTopicDetails(
                name=TOPIC_NAME,
                compartment_id=compartment_id,
            )
        ).data
        print(f"Created topic: {topic.topic_id}")

        sub = control_client.create_subscription(
            create_subscription_details=oci.ons.models.CreateSubscriptionDetails(
                topic_id=topic.topic_id,
                protocol="EMAIL",
                endpoint=RECIPIENT,
                compartment_id=compartment_id,
            )
        ).data
        print(
            f"Created subscription {sub.id}. "
            "Confirm the email link before future notifications are delivered."
        )
    else:
        raise RuntimeError(
            f"Topic {TOPIC_NAME} does not exist. Create it with Terraform first."
        )

    data_client.publish_message(
        topic_id=topic.topic_id,
        message_details=oci.ons.models.MessageDetails(
            title=f"{SHAPE} is available",
            body=message,
        ),
    )
    print("Notification published via OCI Notifications.")


def send_gmail(subject, body):
    if not GMAIL_USER or not GMAIL_APP_PASSWORD:
        return False

    msg = MIMEText(body)
    msg["Subject"] = subject
    msg["From"] = GMAIL_USER
    msg["To"] = RECIPIENT

    context = ssl.create_default_context()
    with smtplib.SMTP_SSL("smtp.gmail.com", 465, context=context) as server:
        server.login(GMAIL_USER, GMAIL_APP_PASSWORD)
        server.sendmail(GMAIL_USER, [RECIPIENT], msg.as_string())

    print("Email sent via Gmail SMTP.")
    return True


def main():
    config, signer = get_config_and_signer()
    compartment_id = get_compartment_id(config)
    home_region = config.get("region", "unknown")

    print(f"Checking {SHAPE} capacity in home region: {home_region}")
    print(f"Compartment: {compartment_id}")

    compute_client = oci.core.ComputeClient(config, signer=signer)
    identity_client = oci.identity.IdentityClient(config, signer=signer)

    available_ads = check_capacity(compute_client, identity_client, compartment_id)

    if not available_ads:
        print(f"{SHAPE} is not available in any AD right now.")
        return

    message = (
        f"Good news! {SHAPE} is available in the following availability domain(s): "
        f"{', '.join(available_ads)}.\n"
        f"Region: {home_region}\n"
        f"You can now run 'terraform apply' to create the instance."
    )
    print(message)

    subject = f"{SHAPE} capacity available in {home_region}"

    try:
        send_ons_notification(config, signer, compartment_id, message)
    except Exception as e:
        print(f"OCI Notifications failed: {e}")

    if GMAIL_USER and GMAIL_APP_PASSWORD:
        try:
            send_gmail(subject, message)
        except Exception as e:
            print(f"Gmail SMTP failed: {e}")


if __name__ == "__main__":
    main()
