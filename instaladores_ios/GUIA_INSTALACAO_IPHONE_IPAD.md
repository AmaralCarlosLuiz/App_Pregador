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

## 🚀 Método 1: Instalação Definitiva na Nuvem (Funciona em 4G/5G/Wi-Fi em qualquer lugar)

O repositório já possui a esteira automática (`.github/workflows/deploy_ios_webapp.yml`) que compila e publica o **Pregador Pro** no servidor seguro do GitHub Pages:

### Passo único para ativar no seu GitHub (1 minuto):
1. Acesse no seu navegador: `https://github.com/AmaralCarlosLuiz/App_Pregador/settings/pages`
2. Em **Build and deployment > Source**, selecione **Deploy from a branch**.
3. Em **Branch**, selecione **`gh-pages`** (pasta `/ (root)`) e clique em **Save**.
4. O link oficial do seu aplicativo ficará ativo em:
   👉 **`https://amaralcarlosluiz.github.io/App_Pregador/`**

### Como instalar nos 3 aparelhos:

#### Opção A — Pelo Arquivo Instalador `.mobileconfig` (`Pregador_Pro_iOS_iPadOS.mobileconfig`)
1. Envie o arquivo `instaladores_ios/Pregador_Pro_iOS_iPadOS.mobileconfig` (por AirDrop, E-mail ou iCloud Drive) para o seu **iPhone 14 Pro Max**, **iPhone 12** e **iPad Air (iOS 12.5.8)** — ou acesse `https://amaralcarlosluiz.github.io/App_Pregador/Pregador_Pro.mobileconfig` pelo **Safari**.
2. O iOS exibirá o aviso: **"Perfil Baixado"**.
3. Abra o app **Ajustes** do iPhone/iPad ➔ toque em **Perfil Baixado** (ou *Geral > Perfis e Gerenciamento de Dispositivo* no iOS 12.5.8) ➔ toque em **Instalar** no canto superior direito.
4. Pronto! O aplicativo **Pregador Pro** aparecerá imediatamente na sua Tela de Início e abrirá em tela cheia!

#### Opção B — Direto pelo Safari ("Adicionar à Tela de Início")
1. Abra o **Safari** no **iPhone 14 Pro Max**, **iPhone 12** ou **iPad Air (iOS 12.5.8)** e acesse:
   `https://amaralcarlosluiz.github.io/App_Pregador/`
2. Toque no ícone **Compartilhar** (quadrado com seta apontando para cima `⬆️`).
3. Role para baixo e toque em **"Adicionar à Tela de Início"** (*Add to Home Screen*).
4. Toque em **Adicionar**. O ícone dourado/azul do **Pregador Pro** será instalado na tela inicial!

---

## 🏠 Método 2: Instalação Imediata via Wi-Fi Local (Sem precisar esperar internet/nuvem)

Se quiser testar ou usar agora mesmo nos seus aparelhos conectados no mesmo Wi-Fi do seu notebook/PC:

1. Dê dois cliques no arquivo:
   `instaladores_ios/INICIAR_SERVIDOR_WIFI_IPHONE_IPAD.bat`
2. Ele mostrará na tela o endereço IP do seu computador (ex.: `http://192.168.1.15:8080`).
3. Abra esse endereço no **Safari** do seu **iPhone 14 Pro Max**, **iPhone 12** e **iPad Air (iOS 12.5.8)** e toque em **Compartilhar ➔ Adicionar à Tela de Início**.
