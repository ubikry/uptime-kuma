<template>
    <div v-if="!collapsed" class="monitor-stats shadow-box">
        <div class="stats-grid">
            <!-- 平均响应时间 (24小时) -->
            <div class="stat-item">
                <div class="stat-label">平均响应时间</div>
                <div class="stat-subtitle">(24{{ $t("hour") }})</div>
                <div class="stat-value">{{ formatPing(avgPing) }}</div>
            </div>

            <!-- 在线时间 (24小时) -->
            <div class="stat-item">
                <div class="stat-label">{{ $t("Uptime") }}</div>
                <div class="stat-subtitle">(24{{ $t("hour") }})</div>
                <div class="stat-value">{{ formatUptime(uptime24) }}</div>
            </div>

            <!-- 在线时间 (30天) -->
            <div class="stat-item">
                <div class="stat-label">{{ $t("Uptime") }}</div>
                <div class="stat-subtitle">(30{{ $t("day") }})</div>
                <div class="stat-value">{{ formatUptime(uptime30) }}</div>
            </div>

            <!-- 在线时间 (1年) -->
            <div class="stat-item">
                <div class="stat-label">{{ $t("Uptime") }}</div>
                <div class="stat-subtitle">(1{{ $t("year") }})</div>
                <div class="stat-value">{{ formatUptime(uptime1y) }}</div>
            </div>

            <!-- 证书有效期 -->
            <div v-if="showCertExpiry && certExpiry" class="stat-item">
                <div class="stat-label">{{ $t("Cert Exp.") }}</div>
                <div class="stat-subtitle">({{ certExpiryDate }})</div>
                <div class="stat-value" :class="certExpiryClass">{{ certExpiry }}</div>
            </div>
        </div>
    </div>
</template>

<script>
export default {
    props: {
        /** 监控器ID */
        monitorId: {
            type: Number,
            required: true,
        },
        /** 是否显示证书到期信息 */
        showCertExpiry: {
            type: Boolean,
            default: false,
        },
        /** 证书到期天数 */
        certExpiryDays: {
            type: Number,
            default: null,
        },
        /** 证书是否有效 */
        validCert: {
            type: Boolean,
            default: true,
        },
        /** 是否折叠 */
        collapsed: {
            type: Boolean,
            default: false,
        },
    },
    computed: {
        /** 当前响应时间 */
        currentPing() {
            return this.$root.currentPingList?.[this.monitorId] || 0;
        },
        /** 24小时平均响应时间 */
        avgPing() {
            return this.$root.avgPingList?.[`${this.monitorId}_24`] || 0;
        },
        /** 24小时在线率 */
        uptime24() {
            return this.$root.uptimeList?.[`${this.monitorId}_24`] || 0;
        },
        /** 30天在线率 */
        uptime30() {
            return this.$root.uptimeList?.[`${this.monitorId}_720`] || 0;
        },
        /** 1年在线率 */
        uptime1y() {
            return this.$root.uptimeList?.[`${this.monitorId}_1y`] || 0;
        },
        /** 格式化证书到期信息 */
        certExpiry() {
            if (!this.showCertExpiry || this.certExpiryDays === null) {
                return null;
            }
            if (!this.validCert) {
                return this.$t("noOrBadCertificate");
            }
            return `${this.certExpiryDays} ${this.$tc("day", this.certExpiryDays)}`;
        },
        /** 证书到期日期（占位，可根据需要实现） */
        certExpiryDate() {
            return "";
        },
        /** 证书到期状态类 */
        certExpiryClass() {
            if (!this.validCert) {
                return "text-danger";
            }
            if (this.certExpiryDays <= 7) {
                return "text-danger";
            }
            return "text-success";
        },
    },
    methods: {
        /** 格式化Ping值 */
        formatPing(ping) {
            if (!ping || ping === 0) {
                return this.$t("notAvailableShort");
            }
            return Math.round(ping) + " ms";
        },
        /** 格式化在线率 */
        formatUptime(uptime) {
            if (uptime === undefined || uptime === null) {
                return this.$t("notAvailableShort");
            }
            let result = Math.round(uptime * 10000) / 100;
            if (result > 100) {
                result = 100;
            }
            return result + "%";
        },
    },
};
</script>

<style lang="scss" scoped>
@import "../assets/vars";

.monitor-stats {
    margin-top: 8px;
    margin-bottom: 8px;
    padding: 10px 12px;
    background: rgba(92, 221, 139, 0.05);
    border-radius: 6px;
    border: 1px solid rgba(92, 221, 139, 0.15);
}

.stats-grid {
    display: grid;
    grid-template-columns: repeat(auto-fit, minmax(100px, 1fr));
    gap: 10px;
    text-align: center;

    @media (max-width: 768px) {
        grid-template-columns: repeat(3, 1fr);
        gap: 8px;
    }
}

.stat-item {
    padding: 6px 8px;
    background: #ffffff;
    border-radius: 4px;
    box-shadow: 0 1px 2px rgba(0, 0, 0, 0.04);
}

.stat-label {
    font-weight: 600;
    font-size: 11px;
    color: #666;
    margin-bottom: 1px;
}

.stat-subtitle {
    font-size: 9px;
    color: #999;
    margin-bottom: 3px;
}

.stat-value {
    font-size: 14px;
    font-weight: bold;
    color: #333;
}

.text-success {
    color: #28a745 !important;
}

.text-danger {
    color: #dc3545 !important;
}

.dark {
    .monitor-stats {
        background: rgba(92, 221, 139, 0.08);
        border-color: rgba(92, 221, 139, 0.2);
    }

    .stat-item {
        background: $dark-bg;
    }

    .stat-label {
        color: #bbb;
    }

    .stat-value {
        color: #eee;
    }
}
</style>
