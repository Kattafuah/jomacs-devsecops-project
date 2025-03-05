package k8svolumes

violation[{"msg": msg}] {
    volume := input.review.object.spec.volumes[_]
    volume.persistentVolumeClaim
    not volume.persistentVolumeClaim.readOnly
    msg := sprintf("Volume '%s' must be read-only.", [volume.name])
}