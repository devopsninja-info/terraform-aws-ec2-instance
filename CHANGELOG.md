## 0.3.0 (April 06, 2022)

NOTES:
* tested against: terraform 1.1.7, aws provider 4.8.0

BREAKING CHANGES:
* individual items in `ingress_cidr_rules` and `ingress_sg_rules` variables have 3 elements now (instead of 2), protocol has been added, please refer to example in variables.tf file

ENHANCEMENTS:
* it is possible to specify protocol for `ingress_cidr_rules` and `ingress_sg_rules`


## 0.2.0 (April 06, 2022)

NOTES:
* tested against: terraform 1.1.7, aws provider 4.8.0

FEATURES:
* new variable `extra_tags` - allows passing additional tags
* new variable `metadata_tags_enabled` - allows enabling metadata tag endpoint
* new variable `bootstrap_s3_bucket` - allows configure bootstrap bucket name

## 0.1.0 (April 05, 2022)

NOTES:
* init module commit
* tested against: terraform 1.1.7, aws provider 4.8.0
