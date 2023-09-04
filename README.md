Welcome to the Telegram Bot App with Docker! 
This application uses [telegram-bot](https://github.com/telegram-bot-rb/telegram-bot) gem.

## Non-command Messages
Messages that aren't recognized as commands will be routed to an external API - [Conversational Order Assistant](https://github.com/IrinaLepekhina/planta_chat). This bot integrates with the API, handling actions like registration and login via JWT tokens and managing token storage and retrieval using Redis.

The Conversational Order Assistant will help process the information and guide the conversation accordingly.

## Commands

- `/start` - Greeting.
- `/help`
- `/memo %text%` - Saves text to session.
- `/remind_me` - Replies with text from session.
- `/keyboard` - Simple keyboard.
- `/inline_keyboard` - Inline keyboard example.
- Inline queries. Enable it in [@BotFather](https://telegram.me/BotFather),
  and your're ready to try 'em.
- `/last_chosen_inline_result` - Your last chosen inline result
  (Enable feedback with sending `/setinlinefeedback`
  to [@BotFather](https://telegram.me/BotFather)).

### Async mode

- Uncomment `async: true` in `secrets.yml`.
- Run and check the logs out.
- More info about [async mode](https://github.com/telegram-bot-rb/telegram-bot#async-mode).