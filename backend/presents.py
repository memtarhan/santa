import json
import uuid

from fastapi import APIRouter
from fastapi import HTTPException, status
from fastapi import WebSocket, WebSocketDisconnect
from pydantic import BaseModel

from connection_manager import ConnectionManager

connection_manager = ConnectionManager()
router = APIRouter()

# a list of presents
# [{present_id: {final_destination: {latitude: float, longitude}]
presents_data = []


class CurrentLocationModel(BaseModel):
    latitude: float = 34.4
    longitude: float = -122.2


@router.post("/presents")
async def wish_for_present(current_location: CurrentLocationModel) -> {}:
    present_id = str(uuid.uuid4().fields[-1])[:5]
    present_data = {
        'present_id': present_id,
        "final_destination": {
            "latitude": current_location.latitude,
            "longitude": current_location.longitude

        }
    }

    presents_data.append(present_data)

    return {
        'message': "Santa will bring you a gift",
        'present_id': present_id,
        'final_destination': {
            'latitude': current_location.latitude,
            'longitude': current_location.longitude
        }
    }


@router.get("/presents")
async def get_presents(is_santa: bool = False) -> {}:
    if is_santa:
        return {
            'presents': presents_data
        }

    else:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Only Santa can view list of presents.")


@router.websocket("/presents/{present_id}")
async def receive_present(websocket: WebSocket, is_santa: bool):
    await connection_manager.connect(websocket)

    if is_santa:
        pass
        # await connection_manager.broadcast(f"Santa is on the job!", exclude=websocket)
    else:
        await connection_manager.broadcast(f"You will receive a gift from Santa", exclude=websocket)

    try:
        while True:
            data = await websocket.receive()

            try:
                response = data['bytes'].decode('UTF-8')
                if is_santa:
                    await connection_manager.broadcast(json.loads(response))

            except KeyError:
                try:
                    response = data['text']
                    if is_santa:
                        await connection_manager.broadcast(json.loads(response))

                except KeyError:
                    connection_manager.disconnect(websocket)
                    # await connection_manager.broadcast(f"That person does not want a present anymore")


    except WebSocketDisconnect:
        connection_manager.disconnect(websocket)
        # await connection_manager.broadcast(f"That person does not want a present anymore")
