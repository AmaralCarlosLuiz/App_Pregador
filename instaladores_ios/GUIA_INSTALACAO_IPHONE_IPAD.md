# 📱 Guia de Instalação no iPhone 14 Pro Max, iPhone 12 e iPad Air (iOS 12.5.8)

**© 2026 - Pregador Pro | Desenvolvido por Carlos Luiz Amaral**

---

## ⚠️ Por que usamos o Instalador Apple WebClip (`.mobileconfig`) + PWA Full-Screen?

Você possui três dispositivos Apple de gerações distintas:
1. **iPhone 14 Pro Max** *(iOS moderno — Dynamic Island)*
2. **iPhone 12** *(iOS moderno — Super Retina XDR)*
3. **iPad Air** *(iOS 12.5.8 — arquitetura Apple A7)*

> **Nota Técnica de Especialista Sênior**:
> As versões atuais do Xcode/Flutter nativo (`.ipa` da App Store) bloquearam suporte ao **iOS 12.5.8** (exigem mínimo iOS 13.0+) e exigem um computador Mac + conta paga Apple Developer (`US$ 99/ano`) para assinar certificados `.ipa`.
>
> Para que **os 3 aparelhos (incluindo o iPad Air com iOS 12.5.8)** rodem o **Pregador Pro** em **Tela Cheia Nativa (sem barras de navegador)**, com ícone próprio na Tela de Início e funcionando 24h por dia sem expirar a cada 7 dias, preparamos **2 métodos oficiais**:

---

## 🚀 Método 1: Instalação Definitiva no iPhone e iPad (Recomendado)

### ⚠️ Atenção Importante sobre o erro *"A versão da entidade não é compatível"*:
Se você tentar abrir o arquivo `.mobileconfig` diretamente pelo aplicativo **Arquivos (Files)** ou pelo **WhatsApp**, o iOS não consegue instalar o perfil e exibe a mensagem *"Erro de Perfil: A versão da entidade não é compatível"*.
Isso é uma restrição de segurança da própria Apple: perfis `.mobileconfig` só podem ser instalados quando baixados pelo **Safari** ou recebidos pelo app **Mail** nativo.

Por isso, o método mais rápido, seguro e **100% livre de erros** é a **Opção A (Navegador Safari ➔ Adicionar à Tela de Início)** abaixo:

---

### 🌟 Opção A — Direto pelo Safari ("Adicionar à Tela de Início") [RECOMENDADO]
1. Abra o navegador **Safari** no seu **iPhone 14 Pro Max**, **iPhone 12** ou **iPad Air** e acesse o endereço do app:
   👉 **`https://amaralcarlosluiz.github.io/App_Pregador/`**
   *(Se estiver no mesmo Wi-Fi do computador, você também pode usar o endereço local gerado pelo arquivo `.bat`, ex: `http://192.168.x.x:8080`)*.
2. Na barra inferior do Safari, toque no ícone de **Compartilhar** (o quadrado com uma seta apontando para cima `⬆️`).
3. Role as opções para cima e toque em **"Adicionar à Tela de Início"** (*Add to Home Screen*).
4. No canto superior direito, toque em **Adicionar**.
5. **Pronto!** O ícone oficial de alta definição do **Pregador Pro** será criado na tela inicial do seu aparelho e abrirá em tela cheia nativa (modo PWA), sem barras de navegador.

---

### 📲 Opção B — Pelo Perfil `.mobileconfig` (Via Safari)
Se preferir instalar via perfil gerenciado WebClip:
1. Abra o **Safari** no seu iPhone ou iPad.
2. Digite ou acesse a URL direta do instalador:
   👉 **`https://amaralcarlosluiz.github.io/App_Pregador/Pregador_Pro.mobileconfig`**
3. O Safari perguntará: *"Este site está tentando baixar um perfil de configuração. Deseja permitir?"* ➔ Toque em **Permitir**.
4. Aparecerá a mensagem: *"Perfil Baixado"*. Toque em **Fechar**.
5. Abra os **Ajustes** do iPhone/iPad ➔ Logo abaixo do seu nome, toque em **Perfil Baixado** (ou em *Ajustes > Geral > VPN e Gerenciamento de Dispositivo*).
6. Toque em **Instalar** (canto superior direito) e confirme.
7. O ícone do **Pregador Pro** aparecerá na Tela de Início.

---

### 🛠️ Como resolver o "404 There isn't a GitHub Pages site here" (Se aparecer no seu link):
Se o link do GitHub Pages exibir a tela 404, significa que a publicação ainda precisa de 1 clique de ativação nas configurações do seu repositório:
1. No computador, abra: `https://github.com/AmaralCarlosLuiz/App_Pregador/settings/pages`
2. Em **Build and deployment > Source**, escolha **GitHub Actions** (ou **Deploy from a branch** selecionando a branch **`gh-pages`**).
3. Salve. Em cerca de 1 a 2 minutos, o GitHub Pages publicará o site com status 200 OK!

---

## 🏠 Método 2: Instalação Imediata via Wi-Fi Local (Sem precisar esperar internet/nuvem)

Se quiser testar ou usar agora mesmo nos seus aparelhos conectados no mesmo Wi-Fi do seu notebook/PC:

1. Dê dois cliques no arquivo:
   `instaladores_ios/INICIAR_SERVIDOR_WIFI_IPHONE_IPAD.bat`
2. Ele mostrará na tela o endereço IP do seu computador (ex.: `http://192.168.1.15:8080`).
3. Abra esse endereço no **Safari** do seu **iPhone 14 Pro Max**, **iPhone 12** e **iPad Air (iOS 12.5.8)** e toque em **Compartilhar ➔ Adicionar à Tela de Início**.

