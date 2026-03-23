<script setup>
import { ref, onMounted, onUnmounted } from 'vue';

const visible = ref(false);
const currentStop = ref(0);
const totalStops = ref(0);
const nextStopName = ref("");
const status = ref("Đang di chuyển");

const playNotification = () => {
    const audio = new Audio('thongbao_bus.mp3');
    audio.volume = 0.5;
    audio.play().catch(e => console.log("Audio play failed:", e));
};

const handleMessage = (event) => {
    const data = event.data;
    if (data.action === "updateHud") {
        visible.value = data.visible;
        currentStop.value = data.current;
        totalStops.value = data.total;
        nextStopName.value = data.nextStop;
        status.value = data.status;
        
        if (data.playSound) {
            playNotification();
        }
    }
};

onMounted(() => {
    window.addEventListener('message', handleMessage);
});

onUnmounted(() => {
    window.removeEventListener('message', handleMessage);
});
</script>

<template>
  <div id="bus-hud" v-if="visible">
    <div class="hud-container">
        <div class="hud-item">
            <span class="label">Stop:</span>
            <span class="value">{{ currentStop }}/{{ totalStops }}</span>
        </div>
        <div class="hud-divider">|</div>
        <div class="hud-item">
            <span class="label">Điểm kế tiếp:</span>
            <span class="value">{{ nextStopName }}</span>
        </div>
        <div class="hud-divider">|</div>
        <div class="hud-item">
            <span class="label">Status:</span>
            <span class="status-value" :class="{
                'moving': !status.includes('đón khách') && !status.includes('Hoàn thành'),
                'waiting': status.includes('đón khách'),
                'done': status.includes('Hoàn thành')
            }">{{ status }}</span>
        </div>
    </div>
  </div>
</template>

<style scoped>
#bus-hud {
    position: absolute;
    bottom: 5%;
    left: 50%;
    transform: translateX(-50%);
    pointer-events: none;
    user-select: none;
}

.hud-container {
    background: rgba(0, 0, 0, 0.7);
    border-radius: 5px;
    padding: 10px 20px;
    color: white;
    display: flex;
    align-items: center;
    box-shadow: 0 0 10px rgba(0, 0, 0, 0.5);
    border-bottom: 3px solid #ffcc00;
}

.hud-item {
    display: flex;
    align-items: center;
    margin: 0 10px;
}

.label {
    font-weight: bold;
    color: #ffcc00;
    margin-right: 8px;
    text-transform: uppercase;
    font-size: 14px;
}

.value {
    font-size: 16px;
    font-weight: 500;
}

.hud-divider {
    color: rgba(255, 255, 255, 0.3);
    font-size: 18px;
}

.status-value {
    font-size: 16px;
    font-weight: bold;
}

.moving {
    color: #00ffcc;
}

.waiting {
    color: #ff9900;
}

.done {
    color: #00ff00;
}
</style>
