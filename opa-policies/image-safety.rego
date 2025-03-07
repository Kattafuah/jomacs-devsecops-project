package kubernetes.validating.images

deny contains msg if {
	input.request.kind.kind == "Pod"

	# The `some` keyword declares local variables. This rule declares a variable
	# called `container`, with the value any of the input request's spec's container
	# objects. It then checks if the container object's `"image"` field does not
	# start with "hooli.com/".
	some container in input.request.object.spec.containers
	not startswith(container.image, "hooli.com/")
	msg := sprintf("Image '%v' comes from untrusted registry", [container.image])
}
