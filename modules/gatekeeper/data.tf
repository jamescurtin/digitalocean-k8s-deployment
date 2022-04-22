data "http" "httpsonly_template" {
  url = "https://raw.githubusercontent.com/open-policy-agent/gatekeeper-library/master/library/general/httpsonly/template.yaml"
}
data "http" "httpsonly_constraint" {
  url = "https://raw.githubusercontent.com/open-policy-agent/gatekeeper-library/master/library/general/httpsonly/samples/ingress-https-only/constraint.yaml"
}

data "http" "uniqueingresshost_template" {
  url = "https://raw.githubusercontent.com/open-policy-agent/gatekeeper-library/master/library/general/uniqueingresshost/template.yaml"
}
data "http" "uniqueingresshost_constraint" {
  url = "https://raw.githubusercontent.com/open-policy-agent/gatekeeper-library/master/library/general/uniqueingresshost/samples/unique-ingress-host/constraint.yaml"
}
