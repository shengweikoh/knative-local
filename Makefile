# Create a local Kubernetes cluster and install Knative Serving and Kourier
create:
	# Create a kind cluster using the specified config
	kind create cluster --name knative --config clusterconfig.yaml

	# Install Knative Serving CRDs
	kubectl apply --filename https://github.com/knative/serving/releases/download/knative-v1.13.0/serving-crds.yaml

	# Install Knative Serving core components
	kubectl apply --filename https://github.com/knative/serving/releases/download/knative-v1.13.0/serving-core.yaml

	# Install Kourier ingress
	kubectl apply --filename kourier.yaml

	# Configure Knative to use Kourier as the ingress class
	kubectl patch configmap/config-network \
		--namespace knative-serving \
		--type merge \
		--patch '{"data":{"ingress-class":"kourier.ingress.networking.knative.dev"}}'

	# Set up domain mapping for local access
	kubectl patch configmap/config-domain \
		--namespace knative-serving \
		--type merge \
		--patch '{"data":{"127.0.0.1.sslip.io":""}}'

# Apply the KNative service
apply:
	kubectl apply --filename service.yaml

# Delete the kind cluster
delete:
	kind delete cluster --name knative

# Check the status of Knative and Kourier pods and services
check:
	kubectl get pods --namespace knative-serving
	kubectl get pods --namespace kourier-system
	kubectl --namespace kourier-system get service kourier
	kubectl get ksvc
	kubectl get pods

# Ping the sample Knative service endpoint
ping:
	curl -v http://helloworld-go.default.127.0.0.1.sslip.io