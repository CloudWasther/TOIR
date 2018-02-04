using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Diagnostics;
using System.IO;
using System.Linq;
using System.Net;
using System.Windows.Forms;

namespace WindowsFormsApp8
{
    public partial class Form1 : Form
    {
        public static ListBoxLog listBoxLog;

        public Form1()
        {
            InitializeComponent();
            listBoxLog = new ListBoxLog(listBox3);
        }

        public void addItemToListBox(string item)
        {
            if (!string.IsNullOrEmpty(item))
            {
                if (!listBox1.Items.Contains(item))
                {
                    listBox1.Items.Add(item);
                }
                else
                {
                    // item already exists in listbox
                }
            }
            else
            {
                // textbox is empty
            }
        }

        private void Form1_Load(object sender, EventArgs e)
        {
            LoadScriptToListbox();

            listboxAllscript = new ContextMenuStrip();
            listboxAllscript.Opening += new CancelEventHandler(contextMenuStrip1_Opening);
            listBox2.ContextMenuStrip = listboxAllscript;

            listboxActivescript = new ContextMenuStrip();
            listboxActivescript.Opening += new CancelEventHandler(contextMenuStrip2_Opening);
            listBox1.ContextMenuStrip = listboxActivescript;

            all_listScript();
            listBoxLog.Log(Level.Info, "WELCOME TO https://toirplus.com/");
        }

        public void all_listScript()
        {
            try
            {
                listBox2.Items.Clear();
                string path = Path.Combine(Environment.CurrentDirectory, "Scripts");

                if (Directory.Exists(path))
                {
                    var filteredFiles = Directory.GetFiles(path, "*.*").Where(file => file.EndsWith("lua")).ToList();
                    for (var i = 0; i < filteredFiles.Count; i++)
                    {
                        //listBox2.Items.Add(Path.GetFileName(filteredFiles[i]));
                        listInfoOffline.Add(Path.GetFileName(filteredFiles[i]));
                    }

                    //DirectoryInfo d = new DirectoryInfo(path);//Assuming Test is your Folder
                    //FileInfo[] Files = d.GetFiles("*.lua"); //Getting lua files

                    //foreach (FileInfo file in Files)
                    //{
                    //    listBox2.Items.Add(file);
                    //}

                    string OnlineInfo = new WebClient().DownloadString(@"https://raw.githubusercontent.com/ToirPlus/ToirplusScript/master/scriptInfo.txt");
                    StringReader sr = new StringReader(OnlineInfo);

                    string line;
                    while ((line = sr.ReadLine()) != null)
                    {
                        string[] words = line.Split('#');
                        if (words[2] == "Scripts")
                        {
                            listInfoOnlineName.Add(Path.GetFileName(words[0]));
                            listInfoOnlineHash.Add(words[1]);
                            listInfoOnlineLink.Add(words[0]);
                        }
                        if (words[2] == "Lib")
                        {
                            listInfoOnlineNameLib.Add(Path.GetFileName(words[0]));
                            listInfoOnlineHashLib.Add(words[1]);
                            listInfoOnlineLinkLib.Add(words[0]);
                        }
                    }

                    listInfoAll = listInfoOffline.Union(listInfoOnlineName).ToList();
                    listInfoAll.Sort();
                    for (var i = 0; i < listInfoAll.Count; i++)
                    {
                        listBox2.Items.Add(listInfoAll[i]);
                    }
                    SyncLibOnline();
                }
            }
            catch (Exception ex)
            {
                Console.WriteLine(ex.Message + "\r\n" + ex.StackTrace + "\r\n" + ex.Source);
            }
        }

        private void contextMenuStrip1_Opening(object sender, CancelEventArgs e)
        {
            listboxAllscript.Items.Clear();
            ToolStripItem item = listboxAllscript.Items.Add("Active Script");
            item.Click += new EventHandler(item1_Click1);

            ToolStripItem item2 = listboxAllscript.Items.Add("Delete Script");
            item2.Click += new EventHandler(item1_Click2);

            ToolStripItem item3 = listboxAllscript.Items.Add("Refresh List");
            item3.Click += new EventHandler(item1_Click3);
        }

        private void contextMenuStrip2_Opening(object sender, CancelEventArgs e)
        {
            listboxActivescript.Items.Clear();
            ToolStripItem item = listboxActivescript.Items.Add("Remove Selected");
            item.Click += new EventHandler(itemlistbox1_Click1);

            ToolStripItem item2 = listboxActivescript.Items.Add("Open Script");
            item2.Click += new EventHandler(itemlistbox1_Click2);

            ToolStripItem item3 = listboxActivescript.Items.Add("Clear List Scripts");
            item3.Click += new EventHandler(itemlistbox1_Click3);
        }

        void item1_Click1(object sender, EventArgs e)
        {
            ToolStripItem clickedItem1 = sender as ToolStripItem;
            //MessageBox.Show("Active Script");

            if (!string.IsNullOrEmpty(listBox2.SelectedItem.ToString()))
            {
                if (!listBox1.Items.Contains(listBox2.SelectedItem.ToString()))
                {
                    //listBox1.Items.Add(listBox2.SelectedItem.ToString());
                    SyncScriptOnline();                    
                }
                else
                {
                    MessageBox.Show("Script is Exists in list active scripts");
                    // item already exists in listbox
                }
            }
            else
            {
                // textbox is empty
            }
            creatconfigfromlistbox();
        }

        void item1_Click2(object sender, EventArgs e)
        {
            ToolStripItem clickedItem2 = sender as ToolStripItem;

            try
            {
                string Name;
                string fullName;
                DirectoryInfo hdDirectoryInWhichToSearch = new DirectoryInfo(Path.Combine(Environment.CurrentDirectory,"Scripts"));
                FileInfo[] filesInDir = hdDirectoryInWhichToSearch.GetFiles("*" + listBox2.SelectedItem.ToString() + "*.*");

                foreach (FileInfo foundFile in filesInDir)
                {
                    Name = foundFile.Name;
                    fullName = foundFile.FullName;
                    if (File.Exists(foundFile.FullName))
                    {
                        File.Delete(foundFile.FullName);
                    }
                    listBox2.Items.Remove(listBox2.SelectedItem);
                }
            }
            catch (Exception)
            {
                MessageBox.Show("need choose a script from list to edit");
            }
        }

        void item1_Click3(object sender, EventArgs e)
        {
            ToolStripItem clickedItem3 = sender as ToolStripItem;
            //MessageBox.Show("Refresh Script");
            all_listScript();
        }

        private void listBox2_SelectedIndexChanged(object sender, EventArgs e)
        {
            try
            {
                string Name;
                string fullName;
                DirectoryInfo hdDirectoryInWhichToSearch = new DirectoryInfo(Path.Combine(Environment.CurrentDirectory,"Scripts"));
                FileInfo[] filesInDir = hdDirectoryInWhichToSearch.GetFiles("*" + listBox2.SelectedItem.ToString() + "*.*");

                foreach (FileInfo foundFile in filesInDir)
                {
                    Name = foundFile.Name;
                    fullName = foundFile.FullName;
                    if (File.Exists(foundFile.FullName))
                    {
                        //richTextBox1.Show();
                        //richTextBox1.Clear();
                        //richTextBox1.LoadFile(Path.Combine(foundFile.Directory.FullName, listBox2.SelectedItem.ToString()), RichTextBoxStreamType.PlainText);
                    }
                }
            }
            catch (Exception)
            {
                //MessageBox.Show("need choose a script from list to edit");
            }
        }

        private void listBox2_MouseDoubleClick(object sender, MouseEventArgs e)
        {
            if (!string.IsNullOrEmpty(listBox2.SelectedItem.ToString()))
            {
                if (!listBox1.Items.Contains(listBox2.SelectedItem.ToString()))
                {
                    //listBox1.Items.Add(listBox2.SelectedItem.ToString());
                    SyncScriptOnline();                    
                }
                else
                {
                    MessageBox.Show("Script is Exists in list active scripts");
                    // item already exists in listbox
                }
            }
            else
            {
                // textbox is empty
            }
            creatconfigfromlistbox();
        }

        private void listBox2_MouseDown(object sender, MouseEventArgs e)
        {
            if (e.Button == MouseButtons.Right)
            {
                listBox2.SelectedIndex = listBox2.IndexFromPoint(e.Location);
                if (listBox2.SelectedIndex != -1)
                {
                    listboxAllscript.Show();
                }
            }
        }

        private ContextMenuStrip listboxAllscript, listboxActivescript;

        void itemlistbox1_Click1(object sender, EventArgs e)
        {
            ToolStripItem clickedItem1 = sender as ToolStripItem;
            // remove seletect from list
            foreach (string s in listBox1.SelectedItems.OfType<string>().ToList())
                listBox1.Items.Remove(s);

            creatconfigfromlistbox();
        }

        void itemlistbox1_Click3(object sender, EventArgs e)
        {
            listBox1.Items.Clear();
            creatconfigfromlistbox();
        }

        void itemlistbox1_Click2(object sender, EventArgs e)
        {
            ToolStripItem clickedItem2 = sender as ToolStripItem;
            try
            {
                string Name;
                string fullName;
                DirectoryInfo hdDirectoryInWhichToSearch = new DirectoryInfo(Path.Combine(Environment.CurrentDirectory, "Scripts"));
                FileInfo[] filesInDir = hdDirectoryInWhichToSearch.GetFiles("*" + listBox1.SelectedItem.ToString() + "*.*");

                foreach (FileInfo foundFile in filesInDir)
                {
                    Name = foundFile.Name;
                    fullName = foundFile.FullName;
                    if (File.Exists(foundFile.FullName))
                    {
                        Process.Start("notepad.exe", Path.Combine(foundFile.Directory.FullName, listBox1.SelectedItem.ToString()));
                    }
                }
            }
            catch (Exception)
            {
                MessageBox.Show("need choose a script from list to edit");
            }
        }

        //public void creatconfigfromlistbox()
        //{
        //    string[] items = listBox1.Items.OfType<object>().Select(item => item.ToString()).ToArray();
        //    string result = string.Join(",", items);
        //    creatConfigBoL(result);
        //}

        private void button1_Click(object sender, EventArgs e)
        {
            string sPath = Path.Combine(Environment.CurrentDirectory, "Scripts\\script.ini");

            System.IO.StreamWriter SaveFile = new System.IO.StreamWriter(sPath);
            SaveFile.WriteLine("[SCRIPT_FILE]");
            //foreach (var item in listBox1.Items)
            //{
            //    SaveFile.WriteLine("script"+ listBox1.Items.Count + " = " + item);
            //}

            for (var i = 0; i < listBox1.Items.Count; i++)
            {
                SaveFile.WriteLine("script" + i.ToString("D3") + " = " + listBox1.Items[i]);
            }

            SaveFile.Close();
        }

        private void button2_Click(object sender, EventArgs e)
        {
            int myInt = 8;
            MessageBox.Show(myInt.ToString("D3"));

            string myString = "20";
            myString = myString.PadLeft(3, '0');
            MessageBox.Show(myString);
        }

        private void button3_Click(object sender, EventArgs e)
        {
            listBox1.Items.Clear();
            string sPath = Path.Combine(Environment.CurrentDirectory, "Scripts\\script.ini");
            List<string> lines = new List<string>();
            using (StreamReader r = new StreamReader(sPath))
            {
                string line;
                while ((line = r.ReadLine()) != null)
                {
                    listBox1.Items.Add(line);

                }
            }
        }

        public void creatconfigfromlistbox()
        {
            string sPath = Path.Combine(Environment.CurrentDirectory, "Scripts\\script.ini");

            System.IO.StreamWriter SaveFile = new System.IO.StreamWriter(sPath);
            SaveFile.WriteLine("[SCRIPT_FILE]");
            for (var i = 0; i < listBox1.Items.Count; i++)
            {
                SaveFile.WriteLine("script" + i.ToString("D3") + " = " + listBox1.Items[i]);
            }
            SaveFile.Close();
        }

        private void button4_Click(object sender, EventArgs e)
        {
            LoadScriptToListbox();
        }

        private void listBox1_MouseDoubleClick(object sender, MouseEventArgs e)
        {
            foreach (string s in listBox1.SelectedItems.OfType<string>().ToList())
                listBox1.Items.Remove(s);

            creatconfigfromlistbox();
        }

        private void pictureBox1_Click(object sender, EventArgs e)
        {
            int index;
            foreach (int i in listBox2.SelectedIndices)
            {
                index = listBox2.SelectedIndex;
                if (index == -1)
                {
                    MessageBox.Show("Item is not selected");
                }
                else
                {
                    if (!string.IsNullOrEmpty(listBox2.SelectedItem.ToString()))
                    {
                        if (!listBox1.Items.Contains(listBox2.SelectedItem.ToString()))
                        {
                            //listBox1.Items.Add(listBox2.SelectedItem.ToString());
                            SyncScriptOnline();                            
                        }
                        else
                        {
                            MessageBox.Show("Script is Exists in list active scripts");
                            // item already exists in listbox
                        }
                    }
                    else
                    {
                        // textbox is empty
                    }
                    creatconfigfromlistbox();
                }
            }                    
        }

        public List<string> listInfoOnlineName = new List<string>();
        public List<string> listInfoOnlineHash = new List<string>();
        public List<string> listInfoOnlineLink = new List<string>();
        public List<string> listInfoOffline = new List<string>();
        public List<string> listInfoAll = new List<string>();

        public List<string> listInfoOnlineNameLib = new List<string>();
        public List<string> listInfoOnlineHashLib = new List<string>();
        public List<string> listInfoOnlineLinkLib = new List<string>();
        public List<string> listInfoAllLib = new List<string>();

        private void button5_Click(object sender, EventArgs e)
        {
            string OnlineInfo = new WebClient().DownloadString(@"https://raw.githubusercontent.com/ToirPlus/ToirplusScript/master/scriptInfo.txt");
            StringReader sr = new StringReader(OnlineInfo);

            string line;
            while ((line = sr.ReadLine()) != null)
            {
                listInfoOnlineName.Add(Path.GetFileName(line));
                //listBox3.Items.Add(Path.GetFileName(line));
            }
        }

        private void button6_Click(object sender, EventArgs e)
        {
            SyncScriptOnline();
        }

        private void SyncScriptOnline()
        {
            try
            {
                for (var i = 0; i < listInfoOnlineLink.Count; i++)
                {
                    if (listBox2.SelectedItem.ToString() == listInfoOnlineName[i])
                    {
                        if (File.Exists(Path.Combine(Environment.CurrentDirectory, "Scripts\\" + listBox2.SelectedItem.ToString())))
                        {
                            if (Md5Hash.ComputeFromFile(Path.Combine(Environment.CurrentDirectory, "Scripts\\" + listBox2.SelectedItem.ToString())).ToUpper() != listInfoOnlineHash[i].ToUpper())
                            {
                                label4.Text = Md5Hash.ComputeFromFile(Path.Combine(Environment.CurrentDirectory, "Scripts\\" + listBox2.SelectedItem.ToString()));
                                Uri url = new Uri(listInfoOnlineLink[i]);
                                sw.Start();
                                using (var client = new WebClient())
                                {
                                    timer1.Start();
                                    listBoxLog.Log(Level.Warning, "Downloading Script...");
                                    client.DownloadFileCompleted += downloadComplet;
                                    client.DownloadProgressChanged += downloadProgress;
                                    client.DownloadFileAsync(url, Path.Combine(Environment.CurrentDirectory, "Scripts\\" + listInfoOnlineName[i]));                                    
                                }
                            }
                        }
                        else
                        {
                            Uri url = new Uri(listInfoOnlineLink[i]);
                            sw.Start();
                            using (var client = new WebClient())
                            {
                                timer1.Start();
                                listBoxLog.Log(Level.Warning, "Downloading Script...");
                                client.DownloadFileCompleted += downloadComplet;
                                client.DownloadProgressChanged += downloadProgress;
                                client.DownloadFileAsync(url, Path.Combine(Environment.CurrentDirectory, "Scripts\\" + listInfoOnlineName[i]));                                
                            }
                        }
                    }
                    else
                    {
                       
                    }
                }
                listBoxLog.Log(Level.Info, listBox2.SelectedItem.ToString() + "Active --> OK");
                listBox1.Items.Add(listBox2.SelectedItem.ToString());        
            }
            catch
            {
                listBoxLog.Log(Level.Error, "Please Choose Any Script in List ALL SCRIPTS");
                //MessageBox.Show("Please Choose Any Script in List ALL SCRIPTS", "An error occured");
            }
        }

        private void SyncLibOnline()
        {
            try
            {
                for (var i = 0; i < listInfoOnlineLinkLib.Count; i++)
                {
                    if (File.Exists(Path.Combine(Environment.CurrentDirectory, "Scripts\\Lib\\" + listInfoOnlineNameLib[i])))
                    {
                        if (Md5Hash.ComputeFromFile(Path.Combine(Environment.CurrentDirectory, "Scripts\\Lib\\" + listInfoOnlineNameLib[i])).ToUpper() != listInfoOnlineHashLib[i].ToUpper())
                        {
                            Uri url = new Uri(listInfoOnlineLinkLib[i]);
                            sw.Start();
                            using (var client = new WebClient())
                            {
                                timer1.Start();
                                listBoxLog.Log(Level.Warning, "Downloading Lib ...");
                                client.DownloadFileAsync(url, Path.Combine(Environment.CurrentDirectory, "Scripts\\Lib\\" + listInfoOnlineNameLib[i]));
                                client.DownloadFileCompleted += LibdownloadComplete;
                                client.DownloadProgressChanged += downloadProgress;
                            }
                        }
                    }
                    else
                    {
                        Uri url = new Uri(listInfoOnlineLinkLib[i]);
                        sw.Start();
                        using (var client = new WebClient())
                        {
                            timer1.Start();
                            listBoxLog.Log(Level.Warning, "Downloading Lib ...");
                            client.DownloadFileAsync(url, Path.Combine(Environment.CurrentDirectory, "Scripts\\Lib\\" + listInfoOnlineNameLib[i]));
                            client.DownloadFileCompleted += LibdownloadComplete;
                            client.DownloadProgressChanged += downloadProgress;
                        }
                    }
                }
            }
            catch
            {
                listBoxLog.Log(Level.Error, "Please Choose Any Script in List ALL SCRIPTS");
                //MessageBox.Show("Please Choose Any Script in List ALL SCRIPTS", "An error occured");
            }
        }

        private void downloadProgress(object sender, DownloadProgressChangedEventArgs e)
        {
            progressBar1.Value = e.ProgressPercentage;

            string speed = string.Format("{0} kb/s", (e.BytesReceived / 1024d / sw.Elapsed.TotalSeconds).ToString("0.00"));
            string perc = e.ProgressPercentage.ToString() + "%";
            label3.Text = string.Format("[{0}] {1} Kb's / {2} Kb's - {3}", perc, (e.BytesReceived / 1024d).ToString("0.00"), (e.TotalBytesToReceive / 1024d).ToString("0.00"), speed);
            listBoxLog.Log(Level.Debug, string.Format("[{0}] {1} Kb's / {2} Kb's - {3}", perc, (e.BytesReceived / 1024d).ToString("0.00"), (e.TotalBytesToReceive / 1024d).ToString("0.00"), speed));
        }

        Stopwatch sw = new Stopwatch();
        private void downloadComplet(object sender, AsyncCompletedEventArgs e)
        {
            
            sw.Reset();
            if (e.Cancelled)
            {
                // download cancel
                //writeLog("download cancelled");
            }
            else
            {
                
                listBoxLog.Log(Level.Info, "Download Complete");
                listBoxLog.Log(Level.Info, listBox2.SelectedItem.ToString() + "Already Active");
                listBoxLog.Log(Level.Debug, listBox2.SelectedItem.ToString() + "  Hash : " + Md5Hash.ComputeFromFile(Path.Combine(Environment.CurrentDirectory, "Scripts\\" + listBox2.SelectedItem.ToString())));              
            }
        }

        private void LibdownloadComplete(object sender, AsyncCompletedEventArgs e)
        {

            sw.Reset();
            if (e.Cancelled)
            {
                // download cancel
                //writeLog("download cancelled");
            }
            else
            {
                listBoxLog.Log(Level.Info, "LIB Download Complete");
            }
        }

        private void postDownloadScript(string linkFromFile)
        {
            try
            {

                string pathScript = Path.Combine(Environment.CurrentDirectory, "Scripts");
                string fromPath = linkFromFile; // Path.GetFullPath(Path.Combine(Environment.CurrentDirectory, scriptFileName)); //Path.GetFullPath(Path.Combine(Environment.GetFolderPath(Environment.SpecialFolder.ApplicationData), "Toir", scriptFileName));
                string toPath = (Path.Combine(pathScript, linkFromFile));// Path.GetFileName(linkFromFile)));
                label4.Text = fromPath;
                label5.Text = toPath;
                if (File.Exists(fromPath))
                {
                    if (File.Exists(toPath))
                    {
                        File.Delete(toPath);
                    }
                    File.Move(fromPath, toPath);
                }     
                else
                    return;
            }
            catch
            {
                //MessageBox.Show("Impossible to move file.", "An error occured");
            }
        }

        private void timer1_Tick(object sender, EventArgs e)
        {
            if (progressBar1.Value == 100)
            {
                progressBar1.Value = 0;
                timer1.Stop();
            }
        }

        public void LoadScriptToListbox()
        {
            if (File.Exists(Path.Combine(Environment.CurrentDirectory, "Scripts\\script.ini")))
            {
                foreach (string line in File.ReadAllLines(Path.Combine(Environment.CurrentDirectory, "Scripts\\script.ini")))
                {
                    if (line.Contains(".lua"))
                    {
                        string[] words = line.Split('=');
                        for (var i = 0; i < words.Length; i++)
                        {
                            string path = Path.Combine(Environment.CurrentDirectory, "Scripts");
                            if (Directory.Exists(path))
                            {
                                string[] files = Directory.GetFiles(path);
                                foreach (string file in files)
                                {
                                    string fn = new FileInfo(file).Name;

                                    if (words[i].Contains(fn))
                                    {
                                        addItemToListBox(words[i].Trim());
                                    }
                                    creatconfigfromlistbox();
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
