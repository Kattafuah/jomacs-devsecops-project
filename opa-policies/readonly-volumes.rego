package kubernetes.validating.volumes

deny[msg] if {
    input.request.kind.kind == "Pod"

    some container in input.request.object.spec.containers
    some volumeMount in container.volumeMounts

    # Check if the volume mount has `readOnly` set to `false` or is missing the `readOnly` field
    not volumeMount.readOnly
    msg := sprintf("Volume '%v' must be mounted as read-only", [volumeMount.name])
}
