#################################### BEFORE SETTINGS ####################################

#################################### SMTP / Emailing #####################
[smtp]
enabled = false
host = localhost:25
user =
# If the password contains # or ; you have to wrap it with triple quotes. Ex """#password;"""
password =
cert_file =
key_file =
skip_verify = false
from_address = admin@grafana.localhost
from_name = Grafana
ehlo_identity =
startTLS_policy =
enable_tracing = false



#################################### AFTER SETTINGS ####################################

#################################### SMTP / Emailing #####################
[smtp]
enabled = true
host = vcloudmatesolutions.com:465
user = sendalerts@vcloudmatesolutions.com
# If the password contains # or ; you have to wrap it with triple quotes. Ex """#password;"""
password = <<your-strong-password>>
cert_file = 
key_file =
skip_verify = false
from_address = sendalerts@vcloudmatesolutions.com
from_name = Grafana Alerts
ehlo_identity =
startTLS_policy =
enable_tracing = false