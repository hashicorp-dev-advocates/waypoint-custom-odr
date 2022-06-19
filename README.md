# Custom On-Demand Runner Image for Waypoint

Dockerfile to build a custom on-demand runner for Waypoint contains the following plugins:

* https://github.com/hashicorp-dev-advocates/waypoint-plugin-terraform
* https://github.com/hashicorp-dev-advocates/waypoint-plugin-consul-release-controller
* https://github.com/hashicorp-dev-advocates/waypoint-plugin-noop

## Custom CA Certificates
The runner can be configured to add custom CA certificates to the certificate cache at run time. This is useful
to enable the runner to communicate with Docker Registries or other services using self signed certificates.

To add custom certificates, set the environment variable `EXTRA_CERTS` to the contents of your certificates.
