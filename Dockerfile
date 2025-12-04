FROM python:3.11-slim

# Set working directory
WORKDIR /app

# Install system dependencies
RUN apt-get update && apt-get install -y \
    gcc \
    && rm -rf /var/lib/apt/lists/*

# Copy requirements first for better caching
COPY requirements.txt .

# Install Python dependencies
RUN pip install --no-cache-dir -r requirements.txt

# Copy application files
COPY excel_comparator.py .
COPY compare_excel.py .
COPY app.py .
COPY templates/ templates/

# Create necessary directories
RUN mkdir -p uploads outputs

# Set environment variables
ENV FLASK_APP=app.py
ENV FLASK_ENV=production
ENV PORT=5000

# Expose port
EXPOSE 5000

# Run the application
CMD gunicorn -w 4 -b 0.0.0.0:$PORT app:app --timeout 120
