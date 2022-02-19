# kubernetes
- [X] Работа с Kubernetes

- [X] 2.9.1.Установите minikube согласно инструкции на официальном сайте.

- [X] 2.9.2.Создайте namespace для деплоя простого веб приложения.

- [X] 2.9.3.Напишите deployments файл для установки в Kubernetes простого веб
      приложения например https://github.com/crccheck/docker-hello-world.

- [X]2.9.4.Установите в кластер ingress контроллер

- [X]2.9.5.Напишите и установите Ingress rule для получения доступа к своему
    приложению. В качестве результата работы сделайте скриншоты результата выполнения команд:
    kubectl get pods -A
    kubectl get svc
    kubectl get all
    а также все написаные вами фалы конфигурации



minikube addons enable ingress - включение ingress-nginx из аддонов minicube
kubens kubetest - переключение namespace по умолчанию на kubetest

kubectl create deployment testpod --image=gcr.io/google-samples/hello-app:1.0 - заменяет деплоймент файл
kubectl expose deployment testpod --type=NodePort --port=8080 - заменяет файл создания сервиса
