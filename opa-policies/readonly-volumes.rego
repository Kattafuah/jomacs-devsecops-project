package k8svolumes

violation[{"msg": "Volume is missing persistentVolumeClaim configuration."}] {
    volume := input.review.object.spec.volumes[_]
    not volume.persistentVolumeClaim
}

violation[{"msg": "Mounted volumes must be read-only."}] {
    volume := input.review.object.spec.volumes[_]
    volume.persistentVolumeClaim
    not volume.persistentVolumeClaim.readOnly
}