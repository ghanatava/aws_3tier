from django.db import migrations, models

class Migration(migrations.Migration):

    dependencies = [
        ('todo', '0001_initial'),  # Assuming 'todo' is your app name and '0001_initial' is the previous migration
    ]

    operations = [
        migrations.AlterField(
            model_name='todo',
            name='title',
            field=models.CharField(max_length=150),  # Modified max_length from 120 to 150
        ),
    ]
