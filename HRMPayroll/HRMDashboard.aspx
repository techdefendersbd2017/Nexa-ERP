<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="HRMDashboard.aspx.cs" Inherits="Nexa_ERP.HRMPayroll.HRMDashboard" %>

<!DOCTYPE html>
<html lang="en">
<head runat="server">
    <meta charset="utf-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1" />
    <title>HRM &amp; Payroll Dashboard</title>
    <script src="https://cdn.tailwindcss.com"></script>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.1/css/all.min.css" />
    <script src="https://cdnjs.cloudflare.com/ajax/libs/Chart.js/4.4.1/chart.umd.min.js"></script>
    <style>
        body { background:#f1f5f9; }
        .kpi { transition: transform .15s ease, box-shadow .15s ease; }
        .kpi:hover { transform: translateY(-3px); box-shadow: 0 10px 24px rgba(15,23,42,.12); }
    </style>
</head>
<body class="min-h-screen text-slate-800">
<form id="form1" runat="server">

    <!-- Header -->
    <div class="bg-slate-900 text-white px-6 py-4 flex flex-wrap items-center justify-between gap-3">
        <div>
            <h1 class="text-xl font-bold"><i class="fa-solid fa-users mr-2 text-blue-400"></i>HRM &amp; Payroll Dashboard</h1>
            <p class="text-xs text-slate-400 mt-1">
                Today: <asp:Label ID="lblToday" runat="server" /> &nbsp;|&nbsp; Month: <asp:Label ID="lblMonth" runat="server" />
            </p>
        </div>
        <asp:LinkButton ID="btnRefresh" runat="server" OnClick="btnRefresh_Click"
            CssClass="bg-blue-600 hover:bg-blue-700 text-white text-sm px-4 py-2 rounded-lg">
            <i class="fa-solid fa-rotate mr-1"></i> Refresh
        </asp:LinkButton>
    </div>

    <asp:Panel ID="pnlWarn" runat="server" Visible="false"
        CssClass="mx-6 mt-4 p-3 rounded-lg bg-amber-50 border border-amber-300 text-amber-800 text-sm">
        <asp:Literal ID="litWarn" runat="server" />
    </asp:Panel>

    <!-- KPI Cards -->
    <div class="p-6 grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 xl:grid-cols-5 gap-5">

        <div class="kpi bg-white rounded-2xl p-5 shadow border-t-4 border-blue-500">
            <div class="flex items-center justify-between">
                <span class="text-sm font-semibold text-slate-500">Total Employee</span>
                <span class="w-10 h-10 rounded-full bg-blue-100 text-blue-600 flex items-center justify-center"><i class="fa-solid fa-users"></i></span>
            </div>
            <div class="text-3xl font-bold mt-3"><asp:Label ID="lblTotalEmp" runat="server" Text="0" /></div>
        </div>

        <div class="kpi bg-white rounded-2xl p-5 shadow border-t-4 border-green-500">
            <div class="flex items-center justify-between">
                <span class="text-sm font-semibold text-slate-500">Total Present</span>
                <span class="w-10 h-10 rounded-full bg-green-100 text-green-600 flex items-center justify-center"><i class="fa-solid fa-user-check"></i></span>
            </div>
            <div class="text-3xl font-bold mt-3"><asp:Label ID="lblPresent" runat="server" Text="0" /></div>
        </div>

        <div class="kpi bg-white rounded-2xl p-5 shadow border-t-4 border-orange-500">
            <div class="flex items-center justify-between">
                <span class="text-sm font-semibold text-slate-500">Total Late</span>
                <span class="w-10 h-10 rounded-full bg-orange-100 text-orange-600 flex items-center justify-center"><i class="fa-solid fa-clock"></i></span>
            </div>
            <div class="text-3xl font-bold mt-3"><asp:Label ID="lblLate" runat="server" Text="0" /></div>
        </div>

        <div class="kpi bg-white rounded-2xl p-5 shadow border-t-4 border-red-500">
            <div class="flex items-center justify-between">
                <span class="text-sm font-semibold text-slate-500">Total Absent</span>
                <span class="w-10 h-10 rounded-full bg-red-100 text-red-600 flex items-center justify-center"><i class="fa-solid fa-user-xmark"></i></span>
            </div>
            <div class="text-3xl font-bold mt-3"><asp:Label ID="lblAbsent" runat="server" Text="0" /></div>
        </div>

        <div class="kpi bg-white rounded-2xl p-5 shadow border-t-4 border-purple-500">
            <div class="flex items-center justify-between">
                <span class="text-sm font-semibold text-slate-500">Total Holiday</span>
                <span class="w-10 h-10 rounded-full bg-purple-100 text-purple-600 flex items-center justify-center"><i class="fa-solid fa-umbrella-beach"></i></span>
            </div>
            <div class="text-3xl font-bold mt-3"><asp:Label ID="lblHoliday" runat="server" Text="0" /></div>
            <div class="text-xs text-slate-400 mt-1">This month</div>
        </div>

        <div class="kpi bg-white rounded-2xl p-5 shadow border-t-4 border-emerald-500">
            <div class="flex items-center justify-between">
                <span class="text-sm font-semibold text-slate-500">This Month Increment</span>
                <span class="w-10 h-10 rounded-full bg-emerald-100 text-emerald-600 flex items-center justify-center"><i class="fa-solid fa-arrow-trend-up"></i></span>
            </div>
            <div class="text-3xl font-bold mt-3"><asp:Label ID="lblIncrement" runat="server" Text="0" /></div>
            <div class="text-xs text-slate-400 mt-1">Employees</div>
        </div>

        <div class="kpi bg-white rounded-2xl p-5 shadow border-t-4 border-yellow-500">
            <div class="flex items-center justify-between">
                <span class="text-sm font-semibold text-slate-500">Total Leave</span>
                <span class="w-10 h-10 rounded-full bg-yellow-100 text-yellow-600 flex items-center justify-center"><i class="fa-solid fa-calendar-minus"></i></span>
            </div>
            <div class="text-3xl font-bold mt-3"><asp:Label ID="lblLeave" runat="server" Text="0" /></div>
            <div class="text-xs text-slate-400 mt-1">On leave today</div>
        </div>

        <div class="kpi bg-white rounded-2xl p-5 shadow border-t-4 border-cyan-500">
            <div class="flex items-center justify-between">
                <span class="text-sm font-semibold text-slate-500">New Join</span>
                <span class="w-10 h-10 rounded-full bg-cyan-100 text-cyan-600 flex items-center justify-center"><i class="fa-solid fa-user-plus"></i></span>
            </div>
            <div class="text-3xl font-bold mt-3"><asp:Label ID="lblNewJoin" runat="server" Text="0" /></div>
            <div class="text-xs text-slate-400 mt-1">This month</div>
        </div>

        <div class="kpi bg-white rounded-2xl p-5 shadow border-t-4 border-rose-500">
            <div class="flex items-center justify-between">
                <span class="text-sm font-semibold text-slate-500">Total Resign</span>
                <span class="w-10 h-10 rounded-full bg-rose-100 text-rose-600 flex items-center justify-center"><i class="fa-solid fa-right-from-bracket"></i></span>
            </div>
            <div class="text-3xl font-bold mt-3"><asp:Label ID="lblResign" runat="server" Text="0" /></div>
            <div class="text-xs text-slate-400 mt-1">This month</div>
        </div>

        <div class="kpi bg-white rounded-2xl p-5 shadow border-t-4 border-slate-500">
            <div class="flex items-center justify-between">
                <span class="text-sm font-semibold text-slate-500">Total Lefty</span>
                <span class="w-10 h-10 rounded-full bg-slate-200 text-slate-600 flex items-center justify-center"><i class="fa-solid fa-person-walking-arrow-right"></i></span>
            </div>
            <div class="text-3xl font-bold mt-3"><asp:Label ID="lblLefty" runat="server" Text="0" /></div>
            <div class="text-xs text-slate-400 mt-1">This month</div>
        </div>

    </div>

    <!-- ===================== নতুন যোগ: কার্ভ / চার্ট সেকশন ===================== -->
    <div class="px-6 pb-8 grid grid-cols-1 lg:grid-cols-2 gap-5">

        <div class="bg-white rounded-2xl p-5 shadow">
            <h2 class="text-sm font-bold text-slate-700 mb-3">
                <i class="fa-solid fa-chart-column text-green-500 mr-1"></i> Attendance - Last 7 Days (Present / Late / Absent)
            </h2>
            <div style="height:300px"><canvas id="chAtt"></canvas></div>
        </div>

        <div class="bg-white rounded-2xl p-5 shadow">
            <h2 class="text-sm font-bold text-slate-700 mb-3">
                <i class="fa-solid fa-user-plus text-cyan-500 mr-1"></i> New Join - Last 6 Months
            </h2>
            <div style="height:300px"><canvas id="chJoin"></canvas></div>
        </div>

        <div class="bg-white rounded-2xl p-5 shadow">
            <h2 class="text-sm font-bold text-slate-700 mb-3">
                <i class="fa-solid fa-right-from-bracket text-rose-500 mr-1"></i> Resign - Last 6 Months
            </h2>
            <div style="height:300px"><canvas id="chResign"></canvas></div>
        </div>

        <div class="bg-white rounded-2xl p-5 shadow">
            <h2 class="text-sm font-bold text-slate-700 mb-3">
                <i class="fa-solid fa-person-walking-arrow-right text-slate-500 mr-1"></i> Lefty - Last 6 Months
            </h2>
            <div style="height:300px"><canvas id="chLefty"></canvas></div>
        </div>

    </div>

    <script>
        // রঙের প্যালেট (আপনার ছবির মতো)
        var palette = ['#d97bb0', '#f2a03d', '#8ee0d0', '#85c1e9', '#c07ed6', '#f5b7b1', '#82e0aa'];

        // বারের উপরে সংখ্যা দেখানোর প্লাগিন
        var valueLabels = {
            id: 'valueLabels',
            afterDatasetsDraw: function (chart) {
                var ctx = chart.ctx;
                chart.getDatasetMeta(0).data.forEach(function (bar, i) {
                    var v = chart.data.datasets[0].data[i];
                    ctx.save();
                    ctx.fillStyle = '#475569';
                    ctx.font = '600 11px sans-serif';
                    ctx.textAlign = 'center';
                    ctx.fillText(v, bar.x, bar.y - 6);
                    ctx.restore();
                });
            }
        };

        function makeBar(id, labels, data, label) {
            var el = document.getElementById(id);
            if (!el) return;
            new Chart(el, {
                type: 'bar',
                data: {
                    labels: labels,
                    datasets: [{
                        label: label,
                        data: data,
                        backgroundColor: labels.map(function (_, i) { return palette[i % palette.length]; }),
                        borderRadius: 4,
                        maxBarThickness: 70
                    }]
                },
                options: {
                    responsive: true,
                    maintainAspectRatio: false,
                    layout: { padding: { top: 20 } },
                    plugins: { legend: { display: false } },
                    scales: {
                        y: { beginAtZero: true, ticks: { precision: 0 }, grid: { color: '#e2e8f0' } },
                        x: { grid: { display: false } }
                    }
                },
                plugins: [valueLabels]
            });
        }

        // হাজিরা: Present / Late / Absent — তিনটি আলাদা বার
        (function () {
            var el = document.getElementById('chAtt');
            if (!el) return;
            var labelPlugin = {
                id: 'groupValueLabels',
                afterDatasetsDraw: function (chart) {
                    var ctx = chart.ctx;
                    chart.data.datasets.forEach(function (ds, di) {
                        chart.getDatasetMeta(di).data.forEach(function (bar, i) {
                            ctx.save();
                            ctx.fillStyle = '#475569';
                            ctx.font = '600 10px sans-serif';
                            ctx.textAlign = 'center';
                            ctx.fillText(ds.data[i], bar.x, bar.y - 5);
                            ctx.restore();
                        });
                    });
                }
            };
            new Chart(el, {
                type: 'bar',
                data: {
                    labels: <%= AttLabels %>,
                    datasets: [
                        { label: 'Present', data: <%= AttData %>,       backgroundColor: '#22c55e', borderRadius: 4, maxBarThickness: 26 },
                        { label: 'Late',    data: <%= AttLateData %>,    backgroundColor: '#f2a03d', borderRadius: 4, maxBarThickness: 26 },
                        { label: 'Absent',  data: <%= AttAbsentData %>,  backgroundColor: '#ef4444', borderRadius: 4, maxBarThickness: 26 }
                    ]
                },
                options: {
                    responsive: true,
                    maintainAspectRatio: false,
                    layout: { padding: { top: 20 } },
                    plugins: { legend: { display: true, position: 'bottom' } },
                    scales: {
                        y: { beginAtZero: true, ticks: { precision: 0 }, grid: { color: '#e2e8f0' } },
                        x: { grid: { display: false } }
                    }
                },
                plugins: [labelPlugin]
            });
        })();
        makeBar('chJoin',   <%= MonLabels %>,  <%= JoinData %>,   'New Join');
        makeBar('chResign', <%= MonLabels %>,  <%= ResignData %>, 'Resign');
        makeBar('chLefty',  <%= MonLabels %>,  <%= LeftyData %>,  'Lefty');
    </script>

</form>
</body>
</html>
