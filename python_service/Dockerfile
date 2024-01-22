FROM python:3.9

WORKDIR /python_service

# Copy the requirements.txt file into the container
COPY ./python_service/requirements.txt .

# Install Python dependencies
RUN pip install --no-cache-dir -r requirements.txt

# Copy the rest of your Python service's files into the container
COPY ./python_service/ .

EXPOSE 50053

CMD ["python", "./main.py"]

