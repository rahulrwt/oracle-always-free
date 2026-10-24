#cloud-config
write_files:
  - path: /opt/check_a1_capacity.py
    permissions: "0755"
    encoding: b64
    content: ${script_b64}
  - path: /etc/default/check_a1_capacity
    permissions: "0600"
    content: |
      USE_INSTANCE_PRINCIPAL=true
      OCI_COMPARTMENT_OCID=${compartment_ocid}
      NOTIFICATION_EMAIL=${notification_email}
      OCI_REGION=${region}
      PROJECT_NAME=${project_name}

runcmd:
  - python3 -m pip install --upgrade oci
  - |
    echo "*/15 * * * * root . /etc/default/check_a1_capacity; /usr/bin/python3 /opt/check_a1_capacity.py >> /var/log/check_a1_capacity.log 2>&1" > /etc/cron.d/check_a1_capacity
  - chmod 644 /etc/cron.d/check_a1_capacity
