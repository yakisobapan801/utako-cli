# utako-cli

## how to use

1. https://console.cloud.google.com/ で適当にプロジェクトを作成する
1. 作成したプロジェクトでYoutube Data APIを使えるようにする
1. Youtube Data API用にAPIキーを作成する
1. ローカルのどこかに下記のようなファイルを用意する
    ファイル名は`credentials.json`など
    ```
    {
      "apiKey": "上で作成したAPIキーをここへペースト"
    }
    ```
1. このリポジトリをローカルへcloneする
1. 実行する
    ```
    cd utako-cli
    swift run utako-cli archive --credentials <apiKeyを保存したファイルのパス> --destination <生成したファイルを保存するパス>
    ```
