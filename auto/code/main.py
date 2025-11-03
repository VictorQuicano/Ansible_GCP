from fastapi import FastAPI
import time
import math

app = FastAPI(title="Algoritmo Pesado API", version="1.0.0")

def algoritmo_pesado_moderado(n: int = 1000000):
    """
    Algoritmo que consume CPU de forma moderada.
    Calcula números primos y realiza operaciones matemáticas intensivas.
    """
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

@app.get("/algoritmo/rapido")
async def ejecutar_algoritmo_rapido(n: int = 100000):
    """
    Versión más rápida del algoritmo para testing.
    """
    resultado = algoritmo_pesado_moderado(n)
    return {
        "status": "completado",
        "version": "rapida",
        "parametros": {"n": n},
        "resultados": resultado
    }

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8000)