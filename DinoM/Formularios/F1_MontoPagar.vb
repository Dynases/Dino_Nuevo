Imports Janus.Windows.GridEX
Imports DevComponents.DotNetBar
Imports System.IO
Imports DevComponents.DotNetBar.SuperGrid
Imports GMap.NET.MapProviders
Imports GMap.NET
Imports GMap.NET.WindowsForms.Markers
Imports GMap.NET.WindowsForms
Imports GMap.NET.WindowsForms.ToolTips
Imports System.Drawing
Imports DevComponents.DotNetBar.Controls
Public Class F1_MontoPagar

    Public TotalVenta As Double
    Public Bandera As Boolean = False
    Public TotalBs As Double = 0
    Public TotalSus As Double = 0
    Public TotalTarjeta As Double = 0
    Private Sub F1_MontoPagar_Load(sender As Object, e As EventArgs) Handles MyBase.Load
        tbMontoBs.Focus()
        txtMontoPagado1.Text = "0.00"
        txtCambio1.Text = "0.00"
    End Sub

    Private Sub tbMontoBs_ValueChanged(sender As Object, e As EventArgs) Handles tbMontoBs.ValueChanged
        tbMontoDolar.Value = 0
        tbMontoTarej.Value = 0

        Dim diferencia As Double = tbMontoBs.Value - TotalVenta
        If (diferencia >= 0) Then
            txtMontoPagado1.Text = TotalVenta.ToString
            txtCambio1.Text = diferencia.ToString

        Else
            txtMontoPagado1.Text = "0.00"
            txtCambio1.Text = "0.00"
        End If

    End Sub

    Private Sub tbMontoDolar_ValueChanged(sender As Object, e As EventArgs) Handles tbMontoDolar.ValueChanged
        tbMontoBs.Value = 0
        tbMontoTarej.Value = 0
        Dim diferencia As Double = (tbMontoDolar.Value * 6.96) - TotalVenta
        If (diferencia >= 0) Then
            txtMontoPagado1.Text = TotalVenta.ToString
            txtCambio1.Text = diferencia.ToString

        Else
            txtMontoPagado1.Text = "0.00"
            txtCambio1.Text = "0.00"
        End If
    End Sub

    Private Sub tbMontoTarej_ValueChanged(sender As Object, e As EventArgs) Handles tbMontoTarej.ValueChanged
        tbMontoDolar.Value = 0
        tbMontoBs.Value = 0

        Dim diferencia As Double = tbMontoTarej.Value - TotalVenta
        If (diferencia >= 0) Then
            txtMontoPagado1.Text = TotalVenta.ToString
            txtCambio1.Text = diferencia.ToString

        Else
            txtMontoPagado1.Text = "0.00"
            txtCambio1.Text = "0.00"
        End If
    End Sub

    Private Sub tbMontoBs_KeyDown(sender As Object, e As KeyEventArgs) Handles tbMontoBs.KeyDown

        If (e.KeyData = Keys.Escape) Then
            TotalBs = 0
            TotalSus = 0
            TotalTarjeta = 0
            Bandera = False
            Me.Close()


        End If
        If (e.KeyData = Keys.Control + Keys.S) Then
            If (tbMontoTarej.Value + tbMontoDolar.Value + tbMontoBs.Value >= TotalVenta) Then
                Bandera = True
                TotalBs = tbMontoBs.Value
                TotalSus = tbMontoDolar.Value
                TotalTarjeta = tbMontoTarej.Value

                Me.Close()

            Else
                ToastNotification.Show(Me, "Debe Ingresar un Monto a Cobrar Valido ", My.Resources.WARNING, 4000, eToastGlowColor.Red, eToastPosition.TopCenter)
            End If


        End If
    End Sub

    Private Sub tbMontoDolar_KeyDown(sender As Object, e As KeyEventArgs) Handles tbMontoDolar.KeyDown

        If (e.KeyData = Keys.Escape) Then
            TotalBs = 0
            TotalSus = 0
            TotalTarjeta = 0
            Bandera = False
            Me.Close()


        End If
        If (tbMontoTarej.Value + tbMontoDolar.Value + tbMontoBs.Value >= TotalVenta) Then
            Bandera = True
            TotalBs = tbMontoBs.Value
            TotalSus = tbMontoDolar.Value
            TotalTarjeta = tbMontoTarej.Value

            Me.Close()

        Else
            ToastNotification.Show(Me, "Debe Ingresar un Monto a Cobrar Valido ", My.Resources.WARNING, 4000, eToastGlowColor.Red, eToastPosition.TopCenter)
        End If
    End Sub

    Private Sub tbMontoTarej_KeyDown(sender As Object, e As KeyEventArgs) Handles tbMontoTarej.KeyDown

        If (e.KeyData = Keys.Escape) Then
            TotalBs = 0
            TotalSus = 0
            TotalTarjeta = 0
            Bandera = False
            Me.Close()


        End If
        If (tbMontoTarej.Value + tbMontoDolar.Value + tbMontoBs.Value >= TotalVenta) Then
            Bandera = True
            TotalBs = tbMontoBs.Value
            TotalSus = tbMontoDolar.Value
            TotalTarjeta = tbMontoTarej.Value

            Me.Close()

        Else
            ToastNotification.Show(Me, "Debe Ingresar un Monto a Cobrar Valido ", My.Resources.WARNING, 4000, eToastGlowColor.Red, eToastPosition.TopCenter)
        End If
    End Sub
End Class