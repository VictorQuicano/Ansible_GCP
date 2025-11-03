#!/bin/bash

#sudo apt-get update
#sudo apt-get install -y python3 python3-pip
#pip3 install flask
python3 -m venv .venv

source .venv/bin/activate
pip install --upgrade pip

cat > /requirements.txt << 'EOF'
dnspython==2.8.0
pymongo==4.15.3
annotated-types==0.7.0
anyio==4.11.0
click==8.3.0
dnspython==2.8.0
fastapi==0.118.3
h11==0.16.0
idna==3.10
motor==3.7.1
pydantic==2.12.0
pydantic_core==2.41.1
pymongo==4.15.3
sniffio==1.3.1
starlette==0.48.0
typing-inspection==0.4.2
typing_extensions==4.15.0
uvicorn==0.37.0
EOF

pip install -r requirements.txt

echo "✅ Entorno virtual creado y dependencias instaladas."

cat > /run.sh << 'EOF'
#!/bin/bash
uvicorn main:app --reload --host 0.0.0.0 --port 8000
EOF

chmod +x /run.sh

cat > /app.py << 'EOF'
from fastapi import FastAPI
import time
import math
app = FastAPI(title="Algoritmo Pesado API", version="1.0.0")
def algoritmo_pesado_moderado(n: int = 1000000):
    start_time = time.time()
    
    # 1. Cálculo de números primos (consumo moderado de CPU)
    primes = []
    for num in range(2, n):
        is_prime = True
        for i in range(2, int(math.sqrt(num)) + 1):
            if num % i == 0:
                is_prime = False
                break
        if is_prime:
            primes.append(num)
    
    # 2. Operaciones matemáticas intensivas
    results = []
    for i in range(len(primes)):
        if i < 1000:  # Limitar para no hacerlo demasiado pesado
            # Cálculo de series matemáticas
            sum_val = 0
            for j in range(1000):
                sum_val += math.sin(primes[i] * j) * math.cos(primes[i] * j)
            results.append(sum_val)
    
    # 3. Ordenamiento de resultados
    results.sort(reverse=True)
    
    end_time = time.time()
    execution_time = end_time - start_time
    
    return {
        "primos_encontrados": len(primes),
        "operaciones_realizadas": len(results),
        "tiempo_ejecucion": round(execution_time, 4),
        "resultado_maximo": round(max(results), 6) if results else 0,
        "resultado_minimo": round(min(results), 6) if results else 0
    }
@app.get("/")
async def root():
    return {"message": "API de algoritmo pesado. Use /algoritmo para ejecutar el algoritmo."}
@app.get("/algoritmo")
async def ejecutar_algoritmo(n: int = 1000000):
    """
    Endpoint para ejecutar el algoritmo pesado.
    
    Args:
        n: Límite superior para buscar números primos (default: 1,000,000)
    
    Returns:
        Resultados del algoritmo incluyendo tiempo de ejecución
    """
    try:
        if n > 5000000:
            return {"error": "El valor de n no puede ser mayor a 5,000,000"}
        
        resultado = algoritmo_pesado_moderado(n)
        
        return {
            "status": "completado",
            "parametros": {"n": n},
            "resultados": resultado
        }
        
    except Exception as e:
        return {"error": f"Error ejecutando el algoritmo: {str(e)}"}
if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8000)
EOF

./run.sh