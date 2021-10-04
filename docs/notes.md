# Useful notes

## Marusya tester
[Skill tester](https://skill-tester.marusia.mail.ru)

## Naming
[StarWars example](https://namingschemes.com/Star_Wars)

## Prometheus 1.x instead of 2.x
So, mmap's in new Prometheus caused `mmap: cannot allocate memory` errors and panics on 32-bit systems.
You can check the developer's answers about this - they have no plans to support 32 bit architectures.
It is suggested to use 1.x version of Prometheus to avoid problems.
Workaround is empirically reduce the retention size and scrap intervals.
https://github.com/prometheus/prometheus/issues/7483
https://github.com/prometheus/prometheus/issues/4392

UPD: Bad news - 1.8.2 has extremely outdated configuration. Suggest to use Victoria Metrics

## Telegram bot
Bot_name: @assol_ml_bot
