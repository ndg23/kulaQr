export const exportToCsv = (data, filename) => {
    const headers = Object.keys(data[0]).join(',')
    const rows = data.map(item => Object.values(item).join(','))
    const csv = [headers, ...rows].join('\n')
    downloadFile(csv, `${filename}.csv`, 'text/csv')
}

export const exportToExcel = (data, filename) => {
    const headers = Object.keys(data[0]).join('\t')
    const rows = data.map(item => Object.values(item).join('\t'))
    const tsv = [headers, ...rows].join('\n')
    downloadFile(tsv, `${filename}.xlsx`, 'application/vnd.ms-excel')
}

export const exportToJson = (data, filename) => {
    const json = JSON.stringify(data, null, 2)
    downloadFile(json, `${filename}.json`, 'application/json')
}

const downloadFile = (content, filename, type) => {
    const blob = new Blob([content], { type })
    const url = URL.createObjectURL(blob)
    const link = document.createElement('a')
    link.href = url
    link.download = filename
    document.body.appendChild(link)
    link.click()
    document.body.removeChild(link)
    URL.revokeObjectURL(url)
}