FROM python:3.12-slim

WORKDIR /app

COPY ./requirements.txt /app

RUN apt-get update
RUN python3 -m pip install --upgrade pip

RUN pip install --no-cache-dir -r requirements.txt

COPY ./run.py /app

ENV PATH="/app:${PATH}"

CMD ["python3", "run.py"]
