document.addEventListener('DOMContentLoaded', initializeCharts);
document.addEventListener('turbo:load', initializeCharts);
document.addEventListener('turbolinks:load', initializeCharts);

function initializeCharts() {
  if (typeof Chart === 'undefined' || typeof chartData === 'undefined') {
    console.warn('Chart.js or chartData is not available.');
    return;
  }

  // Pie Chart: Payment Breakdown
  const breakdownCanvas = document.getElementById('paymentBreakdownChart');
  if (breakdownCanvas instanceof HTMLCanvasElement) {
    new Chart(breakdownCanvas.getContext('2d'), {
      type: 'pie',
      data: {
        labels: ['Principal', chartData.paymentType],
        datasets: [{
          data: [chartData.loanAmount, chartData.totalInterest],
          backgroundColor: ['rgba(13, 110, 253, 0.7)', 'rgba(255, 193, 7, 0.7)'],
          borderColor: ['rgba(13, 110, 253, 1)', 'rgba(255, 193, 7, 1)'],
          borderWidth: 1
        }]
      },
      options: {
        responsive: true,
        maintainAspectRatio: false,
        plugins: {
          legend: { position: 'bottom' },
          tooltip: {
            callbacks: {
              label: ctx => `RM ${ctx.raw.toLocaleString()}`
            }
          }
        }
      }
    });
  }

  // Bar Chart: Amortization Over Time
  const amortCanvas = document.getElementById('amortizationChart');
  if (amortCanvas instanceof HTMLCanvasElement) {
    const yearly = [];
    for (let i = 0; i < 10; i++) {
      const slice = chartData.amortization.slice(i * 12, (i + 1) * 12);
      if (!slice.length) break;

      const principal = slice.reduce((sum, p) => sum + p.principal_payment, 0);
      const profitKey = chartData.paymentType === 'Profit' ? 'profit_payment' : 'interest_payment';
      const interest = slice.reduce((sum, p) => sum + p[profitKey], 0);

      yearly.push({ year: `Year ${i + 1}`, principal, interest });
    }

    new Chart(amortCanvas.getContext('2d'), {
      type: 'bar',
      data: {
        labels: yearly.map(y => y.year),
        datasets: [
          {
            label: 'Principal',
            data: yearly.map(y => y.principal),
            backgroundColor: 'rgba(13, 110, 253, 0.7)',
            borderColor: 'rgba(13, 110, 253, 1)',
            borderWidth: 1
          },
          {
            label: chartData.paymentType,
            data: yearly.map(y => y.interest),
            backgroundColor: 'rgba(255, 193, 7, 0.7)',
            borderColor: 'rgba(255, 193, 7, 1)',
            borderWidth: 1
          }
        ]
      },
      options: {
        responsive: true,
        maintainAspectRatio: false,
        scales: {
          x: { stacked: true },
          y: {
            stacked: true,
            ticks: {
              callback: value => 'RM ' + value.toLocaleString()
            }
          }
        }
      }
    });
  }
}
