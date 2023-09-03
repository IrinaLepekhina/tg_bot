# Example telegram bot app

This app uses telegram-bot gem.

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

By default session is configured to use FileStore at `Rails.root.join('tmp', 'session_store')`.
To use it in production make sure to share this folder between releases
(ex., add to list shared of shared folders in capistrano).
Read more about different session stores in
[original readme](https://github.com/telegram-bot-rb/telegram-bot#session).

### Async mode

- Uncomment `async: true` in `secrets.yml`.
- Run and check the logs out.
- More info about [async mode](https://github.com/telegram-bot-rb/telegram-bot#async-mode).