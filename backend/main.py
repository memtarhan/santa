import logging

import uvicorn
from fastapi import FastAPI

from presents import router as presents_router

app = FastAPI(title="santa",
              description="Santa is bringing you a gift",
              version="1.0.0",
              contact={
                  "name": "Mehmet Tarhan",
                  "email": "hi@memtrhan.com",
                  "url": "https://memtarhan.com"
              },
              license_info={
                  "name": "Apache 2.0",
                  "url": "https://www.apache.org/licenses/LICENSE-2.0.html",
              },
              docs_url="/",
              redoc_url=None)

app.include_router(presents_router)

logger = logging.getLogger("uvicorn")

if __name__ == '__main__':
    uvicorn.run("main:app", reload=True, ws_ping_timeout=None, ws_ping_interval=None)
