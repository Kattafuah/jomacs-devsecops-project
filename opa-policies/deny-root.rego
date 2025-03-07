package kubernetes.admission

import rego.v1

violation contains {"msg": "Containers must not run as root."} if {
	container := input.review.object.spec.containers[_]
	container.securityContext.runAsUser == 0
}
