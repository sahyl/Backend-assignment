import express from "express"
import router from "./routes"
import dotenv from "dotenv"
dotenv.config()

const app = express()
const PORT = process.env.PORT || 3000
app.use(router)

app.listen(PORT , ()=>{
    console.log(`Server running on port ${PORT}`)
})


