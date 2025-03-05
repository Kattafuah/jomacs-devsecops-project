package k8svolumes

contains violation[{"msg": msg}] if {
    volume := input.review.object.spec.volumes[_]
    volume.persistentVolumeClaim
    not volume.persistentVolumeClaim.readOnly
    msg := sprintf("Volume '%s' must be read-only.", [volume.name])
}