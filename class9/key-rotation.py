import boto3
from datetime import date
from email.mime.multipart import MIMEMultipart
from email.mime.text import MIMEText

#First we need to create a client for AWS resource

iam_client = boto3.client('iam')
ses_client = boto3.client('ses')

username="Anupam_0307"
expiry_days = 45
reminder_days = 5
reminder_email_age = expiry_days - reminder_days
To_email = "ghaianupam3@gmail.com"
From_email =  "ghaianupam9@gmail.com"

#https://boto3.amazonaws.com/v1/documentation/api/latest/reference/services/iam/client/list_access_keys.html

# A function that takes input as AWS Username and returns its Access key details

def get_access_keys_age(username):
    response = iam_client.list_access_keys(
        UserName=username,
    ).get('AccessKeyMetadata', [])

    access_keys_info = []
    for item in response:
        if item['Status'] == 'Active':
            access_key_id = item['AccessKeyId']
            create_date = item['CreateDate'].date()  
            age = (date.today() - create_date).days
            access_keys_info.append((access_key_id, age))
    
    return access_keys_info

# response = iam_client.list_access_keys(
# UserName=username,
# ).get('AccessKeyMetadata',[])
 #response()["AccessKeyMetadata"]

def if_key_expired(access_key_id, age, reminder_email_age):
    if age >= reminder_email_age:
        # return f"Reminder: Access key {access_key_id} is {age} days old. Please rotate it."
        return f'''
    <p>Reminder: Access key <strong>{access_key_id}</strong> is <strong>{age}</strong> days old. Please rotate it.</p>
    <p>For more details, visit the <a href="https://us-east-1.console.aws.amazon.com/iam/home?region=us-east-1#/users/details/{username}?section=security_credentials"> Rotate this key here</a>.</p>
    '''

#This code defines a function that processes AWS access keys for a given user, checking if any keys are old enough to warrant sending reminder emails.
#This pattern is common in AWS access key rotation workflows where you want to proactively notify users about aging keys before they become a security risk.

def process_keys(username):
    access_keys_info = get_access_keys_age(username)
    for access_key_id, age in access_keys_info:
        if age >= reminder_email_age:
            return(if_key_expired(access_key_id, age, reminder_email_age))
        
# We need to create Identities in AWS SES - one for the sender and other for the receiver
# It could be individual user or domain name
# aws ses boto3 raw email function

Subject = "Access Key Rotation Reminder"
Body = process_keys(username)


def build_email_message(to_email, from_email, subject, body):
    msg = MIMEMultipart()
    msg['From'] = from_email
    msg['To'] = to_email
    msg['Subject'] = subject

    body_part = MIMEText(body, 'html')
    msg.attach(body_part)

    return msg

def send_email(msg, to_emails):
    response = ses_client.send_raw_email(
        Source=msg["From"],
        Destinations=to_emails,
        RawMessage={"Data": msg.as_string()},
    )
    return response.get('MessageId', None)



def lambda_handler(event,context):
    msg = build_email_message(To_email, From_email, Subject, Body)
    response = send_email(msg, [To_email])
    print(response)
    


# while running locally, uncomment the following lines
if __name__ == "__main__":
    lambda_handler(None, None)


