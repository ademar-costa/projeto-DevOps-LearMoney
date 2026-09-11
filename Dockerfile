FROM ghcr.io/cirruslabs/flutter:3.19.0 AS build

# 1. Cria o usuário e dá permissão total na pasta de instalação do Flutter
RUN useradd -m flutteruser && \
    chown -R flutteruser:flutteruser /sdks/flutter

WORKDIR /app

# 2. Copia os arquivos já dando a posse para o flutteruser
COPY --chown=flutteruser:flutteruser clear_money/ ./

# 3. Muda para o usuário seguro
USER flutteruser

# 4. Autoriza a pasta no Git para evitar o erro de 'dubious ownership'
RUN git config --global --add safe.directory /sdks/flutter

# 5. Baixa os pacotes e compila
RUN flutter pub get
RUN flutter build web --release

# 6. Coloca no Nginx
FROM nginx:alpine
COPY --from=build /app/build/web /usr/share/nginx/html
EXPOSE 80