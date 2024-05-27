
create-packages:
    helm dependency update charts/library-chart
    helm dependency update charts/vscode-python
    helm lint charts/vscode-python
    helm lint charts/library-chart
    helm package charts/vscode-python
    helm package charts/library-chart
    mkdir -p new_charts/
    mv *.tgz new_charts/


migrate-packages:
    git checkout gh-pages
    mv new_charts/*.tgz .

index:
    helm repo index . --url https://afredojala.github.io/onyx-helmcharts

