data "http" "uniqueingresshost_template" {
  url = "https://raw.githubusercontent.com/open-policy-agent/gatekeeper-library/master/library/general/uniqueingresshost/template.yaml"
}
data "http" "uniqueingresshost_constraint" {
  url = "https://raw.githubusercontent.com/open-policy-agent/gatekeeper-library/master/library/general/uniqueingresshost/samples/unique-ingress-host/constraint.yaml"
}
