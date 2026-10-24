#cloud-config
write_files:
  - path: /opt/check_a1_capacity.py
    permissions: "0755"
    encoding: b64
    content: ${script_b64}
  - path: /etc/default/check_a1_capacity
    permissions: "0600"
    content: |
      export USE_INSTANCE_PRINCIPAL=true
      export OCI_COMPARTMENT_OCID=${compartment_ocid}
      export NOTIFICATION_EMAIL=${notification_email}
      export OCI_REGION=${region}
      export PROJECT_NAME=${project_name}

runcmd:
  - python3 -m pip install --upgrade oci
  - |
    echo "*/15 * * * * root . /etc/default/check_a1_capacity; /usr/bin/python3 /opt/check_a1_capacity.py >> /var/log/check_a1_capacity.log 2>&1" > /etc/cron.d/check_a1_capacity
  - chmod 644 /etc/cron.d/check_a1_capacity
