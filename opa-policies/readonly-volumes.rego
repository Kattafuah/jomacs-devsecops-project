package k8svolumes

violation[{"msg": msg}] {
    volume := input.review.object.spec.volumes[_]
    volume.persistentVolumeClaim
    if not volume.persistentVolumeClaim.readOnly {
    msg := sprintf("Volume '%s' must be read-only.", [volume.name])
    }
}