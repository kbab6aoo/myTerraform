# Setup our AWS Provider..!

provider "aws" {
  version = "~> 2.7"

  shared_credentials_file = "/Users/yomiogunyinka/.aws/credentials"
  profile                 = "dev-jcs"
  region                  = "${var.vpc_region}"
}