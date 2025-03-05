package k8svolumes

violation[{"msg": "Mounted volumes must be read-only"}] {
    volume := input.review.object.spec.volumes[_]
    volume.persistentVolumeClaim
    not volume.persistentVolumeClaim.readOnly
}