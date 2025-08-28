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
   # ou
   rails db:migrate
   rails db:seed
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
