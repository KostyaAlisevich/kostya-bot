FROM python:3.10-slim-buster

ENV PYTHONUNBUFFERED=1 \
    PYTHONDONTWRITEBYTECODE=1

WORKDIR /bot

# Берём архивы *.zip из репозитория. Если их несколько (например, с «(1)» в имени),
# выбирается самый свежий по дате файлов внутри, и в логе сборки видно, какой именно.
COPY *.zip /tmp/zips/
RUN python -c "import glob,sys,zipfile; ok=[(max(i.date_time for i in zipfile.ZipFile(f).infolist()),f) for f in glob.glob('/tmp/zips/*.zip') if 'kosta-game-bot-master/src/main.py' in zipfile.ZipFile(f).namelist()]; ok or sys.exit('ОШИБКА: в репозитории нет подходящего архива kosta-game-bot-master.zip'); best=max(ok); print('Найдено подходящих архивов:', len(ok)); print('Используется архив:', best[1], 'от', best[0]); zipfile.ZipFile(best[1]).extractall('/tmp/x')" \
    && cp -a /tmp/x/kosta-game-bot-master/. /bot/ \
    && rm -rf /tmp/x /tmp/zips

# Если pip упадёт, в лог сборки выводится его полный текст ошибки
RUN pip install --no-cache-dir -r requirements.txt > /tmp/pip.log 2>&1 \
    || (echo "===== ОШИБКА pip install =====" && cat /tmp/pip.log && exit 1)
RUN pip list 2>/dev/null | grep -i -E "asyncpg|vkbottle|aiohttp"

CMD ["python", "src/main.py"]
