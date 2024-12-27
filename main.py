import boto3
import os
import psycopg2
from botocore.exceptions import NoCredentialsError

# Initialize Boto3 clients
s3 = boto3.client('s3')
rds = boto3.client('rds')
glue = boto3.client('glue')

def read_from_s3(bucket_name, file_key):
    try:
        response = s3.get_object(Bucket=bucket_name, Key=file_key)
        data = response['Body'].read().decode('utf-8')
        return data
    except NoCredentialsError:
        print("Credentials not available")
        return None

def push_to_rds(data, rds_credentials):
    try:
        conn = psycopg2.connect(
            host=rds_credentials['host'],
            database=rds_credentials['database'],
            user=rds_credentials['user'],
            password=rds_credentials['password']
        )
        cur = conn.cursor()
        cur.execute("INSERT INTO your_table (column_name) VALUES (%s)", (data,))
        conn.commit()
        cur.close()
        conn.close()
    except Exception as e:
        print(f"RDS push failed: {e}")
        return False
    return True

def push_to_glue(data, glue_database, glue_table):
    try:
        glue_client = boto3.client('glue')
        response = glue_client.put_record(
            DatabaseName=glue_database,
            TableName=glue_table,
            RecordData=data
        )
    except Exception as e:
        print(f"Glue push failed: {e}")
        return False
    return True

def main():
    bucket_name = os.environ['S3_BUCKET']
    file_key = os.environ['S3_KEY']
    rds_credentials = {
        'host': os.environ['RDS_HOST'],
        'database': os.environ['RDS_DATABASE'],
        'user': os.environ['RDS_USER'],
        'password': os.environ['RDS_PASSWORD']
    }
    glue_database = os.environ['GLUE_DATABASE']
    glue_table = os.environ['GLUE_TABLE']
    
    data = read_from_s3(bucket_name, file_key)
    if data:
        if not push_to_rds(data, rds_credentials):
            push_to_glue(data, glue_database, glue_table)

if __name__ == "__main__":
    main()