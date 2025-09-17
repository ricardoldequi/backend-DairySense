# DairySense Backend API

## Introdução
Este projeto é uma API Rails 8 para gerenciamento de dispositivos, animais, leituras de sensores e usuários no contexto de monitoramento de rebanhos.

## Requisitos
- Ruby >= 3.2
- Rails >= 8.0
- PostgreSQL
- Bundler

## Instalação
1. Clone o repositório:
   ```bash
   git clone <url-do-repositorio>
   cd backend-DairySense
   ```
2. Instale as dependências:
   ```bash
   bundle install
   ```
3. Configure o banco de dados:
   ```bash
   rails db:setup
   ```
4. Inicie o servidor:
   ```bash
   rails s
   # ou
   bin/dev
   ```

## Autenticação
A autenticação da API é feita via header `Authorization` usando o campo `api_key` do dispositivo.

## Exemplo de requisição (POST de leituras)

Endpoint:
```
POST /readings
```

Headers:
```
Authorization: <api_key_do_dispositivo>
Content-Type: application/json
```

Body:
```json
{
  "readings": [
    {
      "animal_id": 1,
      "temperature": 38.5,
      "sleep_time": 120.5,
      "latitude": -23.567890,
      "longitude": -46.678901,
      "accel_x": 0.12,
      "accel_y": 0.56,
      "accel_z": 9.81,
      "collected_at": "2025-08-26T20:00:00Z"
    }
  ]
}
```

## Resposta de sucesso
```json
{
  "message": "1 leituras salvas com sucesso"
}
```

## Resposta de erro (exemplo)
```json
{
  "error": "Token inválido"
}
```

## Outras rotas
- `GET /readings` — lista todas as leituras
- `POST /devices` — cadastra novo dispositivo (requer serial_number e api_key)
- `GET /devices` — lista dispositivos

## Observações
- O campo `api_key` do dispositivo deve ser um UUID (36 caracteres).
- O banco de dados deve estar migrado e populado com dados de referência (animais, dispositivos, etc).
- Para testar, use ferramentas como Postman ou Insomnia.


consideracoes sobre o app:

- tela inicial:
  - layout diferente para mostrar a sicronizacao
  - comparando os dois aparelhos, um tem dwescricao debaico da escrita do aqila, o outro não
  - sinc inicial demorou cerca de 6 minutos (video no android da empresa)
  - contador de registros não sincornizados/pendente de envio não aparece no menu sanduiche 

6- não é validado se o usuario está inativado enquanto ele está no contexto. Antes era bloqueado o menu de ações e não permitia o usuario fazer qualquier lançamento. Agora, só é validado no momento do login

7- no mongo, se eu altero um usuario, ele parece voltar ao estado inicial a partir de um certo ponto. Ex: editei o usuario-1074, alterei o email para ricardo.dequi02@gmail, apos isso inativei o user, e apos um tempo ele voltou para o email oriinal do usuario, que era fernando@gmail.com, ao consultar o registro no mongo

8- ao fazer logout/login a propriedade e safra já vem previamente selecionada, coisa que não acontecia antes
-Historico

 -  comparativo recomendado x aplicado (print do android da empresa) ton com 0 - ver se isso já acontecia no build antigo


 Sync::Models::AreaDemarcada.new.sync_send_data!

 Apartment::Tenant.switch! 'homologacao-api'


 - ponto que acontecem na versão antiga:
 - tela de tarefas abre mesmo sem ter propriedade selecionada
 - é possivel fazer um tratamento de sementes sem propriedade