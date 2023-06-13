import tkinter as tk
from tkinter import Tk, Label, Button
from tkinter import ttk
from PIL import ImageTk, Image
import minizinc 
from tkinter import filedialog


class aplicacion(tk.Tk):
    def __init__(self):
        super().__init__()
        self.title("Calendario Deportivo")
        self.config(bg="grey")
        self.geometry("1366x768")
        self.resizable(False, False)

        # Cargar la imagen
        imagen = Image.open("fondo.jpg")
        imagen = imagen.resize((1366, 768), Image.ANTIALIAS)  # Ajustar tamaño de la imagen

        # Crear un objeto PhotoImage
        self.imagen_fondo = ImageTk.PhotoImage(imagen)

        # Crear un widget Label y establecer la imagen como su imagen de fondo
        self.label_fondo = Label(self, image=self.imagen_fondo)
        self.label_fondo.place(x=0, y=0, relwidth=1, relheight=1)  # Ajustar al tamaño de la ventana

        # Titulo
        self.titulo = Label(self, text="Calendario Deportivo", fg="black")
        self.titulo.config(font=('Times New Roman', 44), bg="white")
        self.titulo.place(x=420, y=40)

        # Subtitlo que le diga al usuario que es lo que desea hacer 
        self.escoger = Label(self, text="Ponga los siguientes datos para la configuración del calendario o cargue un archivo .txt", fg="black")
        self.escoger.config(font=('Times New Roman', 15), bg="white")
        self.escoger.place(x=100, y=125)

        # Botón para cargar un archivo txt con los datos
        self.cargarDatosTxt = Button(
            self, text="Cargar .txt", command=self.cargarDatosInterfaz)
        self.cargarDatosTxt.pack()
        self.cargarDatosTxt.config(bg="white",width=10, height=2)
        self.cargarDatosTxt.place(x=100, y=180)

        # Crear los widgets de la interfaz
        self.max_label = ttk.Label(self, text="Máximo:")
        self.max_entry = ttk.Entry(self)

        self.min_label = ttk.Label(self, text="MÍnimo:")
        self.min_entry = ttk.Entry(self)

        self.n_label = ttk.Label(self, text="Número de equipos:")
        self.n_entry = ttk.Entry(self)

        self.matrix_label = ttk.Label(self, text="Matiz de distancias:")
        self.matrix_entry = tk.Text(self, width=20, height=15)
        self.matrix_entry.configure(font=("sans-serif", 12), borderwidth=0, relief=tk.RAISED, highlightthickness=1)

        # Poner los widgets
        # Max
        self.max_label.pack()
        self.max_label.place(x=100, y=300)
        self.max_label.config(font=('Times new roman', 12))

        self.max_entry.pack()
        self.max_entry.place(x=180, y=300)

        # Min
        self.min_label.pack()
        self.min_label.place(x=100, y=350)
        self.min_label.config(font=('Times new roman', 12))

        self.min_entry.pack()
        self.min_entry.place(x=180, y=350)

        # n
        self.n_label.pack()
        self.n_label.place(x=100, y=400)
        self.n_label.config(font=('Times new roman', 12))

        self.n_entry.pack()
        self.n_entry.place(x=250, y=400)

        # Distancia
        self.matrix_label.pack()
        self.matrix_label.place(x=100, y=450)
        self.matrix_label.config(font=('Times new roman', 12))

        self.matrix_entry.pack()
        self.matrix_entry.place(x=250, y=450)

        # Botón de crear un archivo DatosCalDep.dzn con los datos proporcionados en la interfaz
        self.crearDzn = Button(
            self, text="Crear archivo .dzn", command=self.crearArchivoDzn)
        self.crearDzn.pack()
        self.crearDzn.config(bg="white",width=20, height=2)
        self.crearDzn.place(x=450, y=685) 
        # Ejecute el modelo genérico CalDep.mzn sobre los datos proporcionados
        # Despliegue los resultados de la solución

    # Función que sirve para leer el archivo txt y ponerlo en la interfaz
    def cargarDatosInterfaz(self):
        file = tk.filedialog.askopenfile(filetypes=[("Text Files", "*.txt")])
        if file:
            # Read the data from the file and populate the entry fields
            data = file.read().splitlines()
            self.n_entry.insert(tk.END, data[0])
            self.min_entry.insert(tk.END, data[1])
            self.max_entry.insert(tk.END, data[2])
            self.matrix_entry.insert(tk.END, "\n".join(data[3:]))
            file.close()

    
    def crearArchivoDzn(self):
        # Get the data from the entry fields
        max_value = self.max_entry.get()
        min_value = self.min_entry.get()
        n_value = self.n_entry.get()
        matrix_data = self.matrix_entry.get("1.0", tk.END).strip()

        # Format the matrix data with proper indentation and line breaks
        matrix_data = matrix_data.replace('\n', '\n|')
        matrix_data = matrix_data.replace(' ', ', ')
        matrix_data = matrix_data[:-2]  # Remove the trailing comma and newline character

        # Write the data to a file
        with open("DatosCalDep.dzn", "w") as file:
            file.write(f"n = {n_value};\n")
            file.write(f"Min = {min_value};\n")
            file.write(f"Max = {max_value};\n")
            file.write(f"Distancia = [|{matrix_data}\n0|];\n")

        # Run the MiniZinc model
        model = minizinc.Model()
        model.add_file("CalDep.mzn")
        instance = minizinc.minizinc(model)
        instance["data"] = "DatosCalDep.dzn"
        result = instance.solve("gecode")

        # Display the results
        result_text = "Results:\n"
        for item in result:
            result_text += str(item) + "\n"
        print(result_text)



if __name__ == "__main__":
    app = aplicacion()
    app.mainloop()
