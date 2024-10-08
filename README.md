Aqui está uma versão formatada do README para o Slidy:

---

# Slidy

**Slidy** é uma CLI que funciona como gerenciador de pacotes, pipeline de scripts e gerador de templates para Flutter. Com ele, você pode gerar Módulos, Páginas, Widgets, BLoCs, Controllers, testes e muito mais.

## Instalação

Você pode instalar o Slidy de várias maneiras:

### Choco (Windows)

```bash
choco install slidy
```

### Homebrew (macOS e Linux)

```bash
brew tap Flutterando/slidy
brew install slidy
```

### Outros Sistemas Operacionais

Para acessar todas as versões binárias, [clique aqui](https://github.com/Flutterando/slidy/releases).

### Flutter/Dart Diretamente

```bash
dart pub global activate slidy
```

## Hello World!

Após instalar, execute o comando para verificar a versão do Slidy. Se o comando for concluído com sucesso, o Slidy foi instalado corretamente.

```bash
slidy --version
```

## Slidy Pipeline

Organize scripts para serem executados, automatizando processos. Todos os passos podem ser configurados em um arquivo chamado `slidy.yaml`.

```bash
slidy run cleanup
```

**Exemplo de `slidy.yaml`:**
```yaml 
slidy: '1'
variables:
  customMessage: "Complete"    # Usado como ${Local.var.customMessage}

scripts:
  # Comando simples (slidy run doctor)
  doctor: flutter doctor

  # Comando descritivo (slidy run clean)
  clean:
    name: "Clean"
    description: 'Minha descrição'
    run: flutter clean

  # Comando em etapas (slidy run cleanup)   
  cleanup:
    description: "Limpar projeto"
    steps:
      - name: "Clean"
        run: flutter clean
        
      - name: "GetPackages"
        description: "Obter pacotes"
        run: flutter pub get

      - name: "PodClean"
        description: "Executar pod clean"
        shell: bash   # Padrão: command. Opções: (command|bash|sh|zsh|pwsh)
        condition: "${System.operatingSystem} == macos"
        working-directory: ios
        run: |-
          rm Podfile.lock
          pod deintegrate
          pod update
          pod install

      - run: echo ${Local.var.customMessage} 
```

### Propriedades

| Propriedade  | Tipo    | Descrição |
|--------------|---------|-----------|
| `slidy`      | string  | Versão da pipeline do Slidy |
| `variables`  | object  | Variáveis locais. Ex.:<br>${Local.var.[VariableName]} |
| `scripts`    | object  | Adiciona scripts executáveis pelo nome |

### Propriedades dos Scripts

Adicione scripts personalizados. <br>
O nome da propriedade pode ser invocado usando o comando `slidy run`.

**Exemplo Simples:**

```yaml
scripts:
  runner: flutter pub run build_runner build --delete-conflicting-outputs
```

Execute este script usando:

```bash
slidy run runner
```

**Exemplo Completo:**

```yaml
scripts:
  runner: 
    name: "Runner"
    description: "Executar build_runner"
    run: flutter pub run build_runner build --delete-conflicting-outputs
```

| Propriedade           | Tipo    | Descrição |
|-----------------------|---------|-----------|
| `run`                 | string  | Script a ser executado |
| `name`                | string  | Nome do script |
| `description`         | string  | Descrição do script |
| `shell`               | string  | Opções: <br>- command (padrão)<br>- bash<br>- sh<br>- zsh<br>- pwsh |
| `working-directory`   | string  | Diretório de execução |
| `environment`         | object  | Adicionar variáveis de ambiente |
| `steps`               | array   | Executar múltiplos scripts em sequência |

**Nota:** As propriedades `STEPS` ou `RUN` devem ser usadas. Não é permitido usar ambas ao mesmo tempo.

**Exemplo com Etapas:**

```yaml
scripts:
  cleanup:
    description: "Limpar projeto"
    steps:
      - name: "Clean"
        run: flutter clean
        
      - name: "GetPackages"
        description: "Obter pacotes"
        run: flutter pub get

      - name: "PodClean"
        description: "Executar pod clean"
        shell: bash 
        condition: "${System.operatingSystem} == macos"
        working-directory: ios
        run: |-
          rm Podfile.lock
          pod deintegrate
          pod update
          pod install

      - run: echo ${Local.var.customMessage} 
```

### Propriedades das Etapas

| Propriedade           | Tipo    | Descrição |
|-----------------------|---------|-----------|
| `run`                 | string  | Script a ser executado |
| `name`                | string  | Nome da etapa |
| `description`         | string  | Descrição da etapa |
| `shell`               | string  | Opções: <br>- command (padrão)<br>- bash<br>- sh<br>- zsh<br>- pwsh |
| `working-directory`   | string  | Diretório de execução |
| `environment`         | object  | Adicionar variáveis de ambiente |
| `condition`           | boolean | Se verdadeiro, executa o script |

**Nota:** O arquivo principal é chamado `slidy.yaml`, mas se você quiser chamar outros arquivos, use a flag **--schema** do comando run. <br>`slidy run command --schema other.yaml`

## Gerenciador de Pacotes

Instale, desinstale e encontre pacotes via linha de comando.

```bash
# Instalar pacote
slidy install bloc

# Instalar pacote com versão específica
slidy install flutter_modular@4.0.1

# Instalar pacote em dev_dependencies
slidy install mocktail --dev

# Encontrar pacote por consulta
slidy find "Shared preferences"

# Mostrar versões do pacote
slidy versions dio
```

## Gerador de Templates

O objetivo do Slidy é ajudar a estruturar seu projeto de maneira padronizada. Ele organiza seu aplicativo em **Módulos** formados por páginas, repositórios, widgets, BloCs, e também cria testes unitários automaticamente. O módulo facilita a injeção de dependências e BloCs, incluindo o descarte automático. O Slidy também auxilia na instalação, atualização e remoção de dependências e pacotes. O melhor é que você pode fazer tudo isso executando um único comando.

Percebemos que a ausência de um padrão de projeto afeta a produtividade de muitos desenvolvedores, então estamos propondo um padrão de desenvolvimento junto com uma ferramenta que imita as funcionalidades do NPM (NodeJS) e também a geração de templates (semelhante ao Scaffold).

### Sobre o Padrão Proposto

A estrutura que o Slidy oferece é similar ao MVC, onde uma página mantém suas próprias **classes de lógica de negócios (BloC)**.

Recomendamos que você use [flutter_modular](https://pub.dev/packages/flutter_modular) ao estruturar com o Slidy. Ele oferece a **estrutura de módulo** (extensão do WidgetModule) e injeção de dependências/BLoCs, ou você provavelmente encontrará um erro.

Para entender o **flutter_modular**, consulte o [README](https://github.com/Flutterando/modular/blob/master/README.md).

Também utilizamos o **Padrão de Repositório**, de modo que a estrutura de pastas é organizada em **módulos locais** e um **módulo global**. As dependências (repositórios, BloCs, modelos, etc.) podem ser acessadas por toda a aplicação.

### Comandos

**Start:**
Cria uma estrutura básica para o seu projeto (certifique-se de que você não tem dados na pasta "lib").

```bash
slidy start
```

### Generate

Crie um módulo, página, widget ou repositório de acordo com a opção.<br>
O gerador do Slidy suporta mobx, bloc, cubit, rx_notifier e triple.

**Opções:**

Crie um novo módulo com **slidy generate module**:

```bash
slidy generate module manager/product
```

Crie uma nova página com **slidy generate page**:

```bash
slidy generate page manager/product/pages/add_product
```

Crie um novo widget com **slidy generate widget**:

```bash
slidy generate widget manager/product/widgets/product_detail
```

Crie um novo repositório com **slidy generate repository**:

```bash
slidy g r manager/product/repositories/product
```

Crie um novo rx_notifier com **slidy generate rx**:

```bash
slidy g rx manager/product/page/my_rx_notifier
```

Crie um novo triple com **slidy generate t**:

```bash
slidy g t manager/product/page/my_triple
```

Crie um novo cubit com **slidy generate c**:

```bash
slidy g c manager/product/page/my_cubit
```

Crie um novo mobx com **slidy generate mbx**:

```bash
slidy g mbx manager/product/page/my_store
```

Para mais detalhes, [Grupo Telegram Flutterando](https://t.me/flutter
