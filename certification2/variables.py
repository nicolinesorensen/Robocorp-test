from RPA.Robocorp.Vault import Vault

secret = Vault().get_secret("websitedata")
URL = secret["https://robotsparebinindustries.com/#/robot-order"]
