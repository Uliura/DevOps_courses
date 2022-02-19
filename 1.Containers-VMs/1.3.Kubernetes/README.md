# Put header here
minikube addons enable ingress - включение ingress-nginx из аддонов minicube
kubens kubetest - переключение namespace по умолчанию на kubetest

kubectl create deployment testpod --image=gcr.io/google-samples/hello-app:1.0 - заменяет деплоймент файл
kubectl expose deployment testpod --type=NodePort --port=8080 - заменяет файл создания сервиса
