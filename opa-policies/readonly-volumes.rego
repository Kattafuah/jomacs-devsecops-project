package kubernetes.admission

import rego.v1

violation contains {"msg": "Mounted volumes must be read-only."} if {
	volume := input.review.object.spec.volumes[_]
	volume.persistentVolumeClaim
	not volume.persistentVolumeClaim.readOnly
}
