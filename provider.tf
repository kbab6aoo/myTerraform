# Setup our AWS Provider..!

provider "aws" {
  version = "~> 2.7"

  shared_credentials_file = "/../../.aws/credentials"
  profile                 = "dev-jcs"
  region                  = "${var.vpc_region}"
}