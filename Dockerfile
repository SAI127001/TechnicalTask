FROM python:3.9-slim

# Set environment variables
ENV S3_BUCKET=mybucket
ENV S3_KEY=myfile.txt
ENV RDS_HOST=myrdsinstance.us-east-1.rds.amazonaws.com
ENV RDS_DATABASE=mydatabase
ENV RDS_USER=myuser
ENV RDS_PASSWORD=mypassword
ENV GLUE_DATABASE=mygluedatabase
ENV GLUE_TABLE=mygluetable

# Install dependencies
COPY requirements.txt .
RUN pip install -r requirements.txt

# Copy the application
COPY main.py .

# Run the application
CMD ["python", "main.py"]