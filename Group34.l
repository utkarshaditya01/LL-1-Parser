/* Definition Section */ 
%{ 
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#define SIZE 100 
#define BUFFER_SIZE 1000
#include <iostream>
#include <fstream>
#include <vector>
#include <set>
#include <map>
#include <stack>

using namespace std;

char new_terminal[2]="Z"; //For introducing new variables
%} 


/*Rule Section*/ 
%% 
%(.*)|" " {/* No action is assigned, to remove  comments */} ;

%% 

/*Driver function*/ 

int checkRecursion(char s[100]) // Returns 1 if recursion is present
{
	int length=strlen(s);
	if(s[0]==s[3])
	{
		return 1;
	}
	for(int i=0;i<length;i++)
	{
		if(s[i]=='|' && s[i+1]==s[0])
		return 1;
	}
	return 0;
}
void indirectElimination() // method to eliminate recursion 
{
    char production[100][SIZE]; //For Existing Productions
    char newpps[100][SIZE]; //For New Productions
    int ncount=0; //New Production Count
    int count=0; //Existing Production Count
    
    //Creating RecursionRemoved.txt to store recursion eliminated grammar.
    FILE *fptr;
    fptr = fopen("RecursionRemoved.txt", "w");
    fprintf(fptr,"\n");
    fclose(fptr);

    //Reading Input Grammar 
    static const char filename[] = "grammar.txt";
    FILE *file = fopen(filename,"r");
    if(file!=NULL)
    {
        char line[128];
        while(fgets(line,sizeof line,file) != NULL ) /* read a line */
        {
            if(strlen(line)==1) //Skip if Line does not have production.
            continue;
            strcpy(production[count],line);
            // printf("%s", buffer);
            count++;
        }
        fclose ( file );
    }
    else
    {
        perror ( filename );
    }
    
    char seen[100];//Keeping track of what non-terminals we have seen
    
    printf("\nGiven Grammar is:\n");
    //Storing The ORDER of variables to remove INDIRECT recursion
    for(int i=0;i<count;i++)
    {
        printf("%s",production[i]);
        seen[i]=production[i][0];
    }

	//Creating 2 temporary strings to keep the new producionts which would be formed.
    char tmp1[100]="";
    char tmp2[100]="";

    // the nested loops are for copying the substrings and finding index mostly.
    for(int i=0;i<count;i++)//checking all productions 
    {
    	int newpp=0; //flag to mark if new production gets created
        for(int j=i-1;j>=0;j--) //checking if production has already seen variables from the ORDER
        {
            for(int k=0;k<strlen(production[i]);k++) //Going through the production to check if seen variable is there 
            {
                if(production[i][k]=='>' || production[i][k]=='|')
                {
                    
                    // printf("%c %c\n",production[i][k+1],seen[j]);
                    if(production[i][k+1]==seen[j])   //If seen variable found, then replace the productions accordingly
                    {
                        strcpy(tmp1,"");
                        // printf("HEllos");
                        // printf("\n%c %c",production[i][k+1],seen[j]);
                        for(int z=0;z<k+1;z++)
                        {
                            newpp=1;            //marking that new production is formed.
                            
                            strncat(tmp1,&production[i][z],1);          //keeping the production same till the variable index is found
                        }
                        //printf("%s\n",tmp1);
                        for(int z=3;z<strlen(production[j])+1;z++)     //copying from other production
                        {
                            if(production[j][z]=='|' || production[j][z]=='\0' )  
                            {
                                for(int m=k+2;m<strlen(production[i]);m++)
                                {
                                    
                                    if(production[i][m]=='|' || production[i][m]=='\n')
                                    {
                                        char hash='|';
                                        strncat(tmp1,&hash,1);
                                        break;
                                    }
                                    if (production[i][m]=='\n' && (m==strlen(production[i])-2))
                                    {
                                        char hash='|';
                                        strncat(tmp1,&hash,1);
                                        break;
                                    }
                                    strncat(tmp1,&production[i][m],1);
                                }
                                continue;
                            }
                            strncat(tmp1,&production[j][z],1);
                        }
                        
                        int flagpipe=0;
                        int firstpipe=0;
                        for(int z=k+2;z<strlen(production[i]);z++) //copying the remaining part of the current production
                        {
                            if(production[i][z]=='|' && firstpipe==0)
                            {
                                flagpipe=1;
                                firstpipe=1;
                                continue;
                            }
                            if(flagpipe==1)
                            {
                                strncat(tmp1,&production[i][z],1);          
                            }
                           
                        }
                        int gglen=strlen(tmp1);
                        //printf("This %c",tmp1[gglen-1]);
                        if(tmp1[gglen-1]=='|')   //if production ends in pipe, remove pipe
                        {
                            tmp1[gglen-1]='\0';
                        }
                        //printf("%s\n",tmp1);
                        goto A;             // if new production is created we have to replace the current production with the new one,and again check the new one

                    }
                }
            }
        }
    A:
    if(newpp==1) // Only if new production is created
    {
        strcpy(production[i],tmp1);
        //printf("this %s",production[i]);
        i=i-1;       //so that we check the current production again
        
        continue;
      }
    
    if (checkRecursion(production[i])==1)      //checking for direct recusion
	    {
            char s[100];
    		strcpy(s,production[i]);
			int length=strlen(s);
			int index=2;
			char temp1[100]=""; // for the 2 new productions
			char temp2[100]="";
			
			int neww=1,flag=0,new2=1;
			char pipe='|';
			for (int i=0;i<length;i++) // Dividing the current production into 2 new productions
			{
				if(s[index+1]==s[0])  // if Direct recursion is there,adding in temp1
				{
					i=index+2;
					if(neww==1)
					{
						strcat(temp1,new_terminal);
						neww=0;
						flag=1;
						new_terminal[0]=new_terminal[0]-1;
						strcat(temp1,"->");
					}
					while(s[i]!='|' && s[i]!='\0')
					{
						strncat(temp1,&s[i],1);
						i++;
					}
					new_terminal[0]=new_terminal[0]+1;
					strcat(temp1,new_terminal);
					new_terminal[0]=new_terminal[0]-1;
					strncat(temp1,&pipe,1);
					index=i;
				}
				else if(s[index+1]!=s[0])  // if direct recursion is not there , adding in temp2
				{
					i=index+1;
					if(new2==1)
					{
						strncat(temp2,&s[0],1);
						new2=0;
						strcat(temp2,"->");
					}
					while(s[i]!='|' && s[i]!='\0')
					{
						strncat(temp2,&s[i],1);
						i++;
					}
					if(flag==1)
					{
						new_terminal[0]=new_terminal[0]+1;
						strcat(temp2,new_terminal);
						new_terminal[0]=new_terminal[0]-1;
					}
					else
					{
						strcat(temp2,new_terminal);
					}
					
					
					strncat(temp2,&pipe,1);
					index=i;
				}
			}
			if (flag==1) //removing extra epsilon
			{
				strcat(temp1,"#");	
			}
			
			
			int size1 = strlen(temp2); //Total size of string
			temp2[size1-1] = '\0';
			//printf("%s\n",temp2);
			char tmp3[100]="";
			for(int i =0;i<strlen(temp2);i++)
			{
				if(i==strlen(temp2)-2 || temp2[i]=='#')
				{
					continue;
				}
				else
				{
					//printf("%c",temp2[i]);
					strncat(tmp3,&temp2[i],1);
				}
			}
			//printf("\n");
			
			strcpy(production[i],tmp3);  //replacing the current production with new one
			//printf("%s\n",temp1);
			strcpy(newpps[ncount],temp1);   //storing the new production 
			ncount++;
				}
				
			}
			// Writing the new grammar in RecursionRemoved.txt
			FILE *fptr2;

			fptr2 = fopen("RecursionRemoved.txt", "w");
			fprintf(fptr2,"\n");
			
			printf("\nRecursion Removed Grammar is:\n");
			for(int i=0;i<count;i++)
			{
				printf("%s\n",production[i]);
				//fprintf(fptr2,"%s\n",production[i]);
				for(int t=0;t<strlen(production[i]);t++)
				{
					if(production[i][t]=='|')
				{
					fprintf(fptr2,"\n%c->",production[i][0]);
				}
				else
				{
					fprintf(fptr2,"%c",production[i][t]);
				}

				}
				fprintf(fptr2,"\n");  
			}
			for(int i=0;i<ncount;i++)
			{
				printf("%s\n",newpps[i]);
				//fprintf(fptr2,"%s\n",newpps[i]);
				for(int t=0;t<strlen(newpps[i]);t++)
				{
					if(newpps[i][t]=='|')
				{
					fprintf(fptr2,"\n%c->",newpps[i][0]);
				}
				else
				{
					fprintf(fptr2,"%c",newpps[i][t]);
				}

				}
				fprintf(fptr2,"\n");           
			}
			fprintf(fptr2,"\n");
			fclose(fptr2);

    
}
void find_first(vector< pair<char, string> > gram, 
	map< char, set<char> > &firsts, 
	char non_term); 

void find_follow(vector< pair<char, string> > gram, 
	map< char, set<char> > &follows, 
	map< char, set<char> > firsts, 
	char non_term); 

void leftFactor()
{   
    char production[100][SIZE]; //for existing productions
    char new1[100][SIZE]; //for new productions
	int countnew1=0;  //count of new productions
    int count=0;  // count of existing productions

	//reading the recursion rmeoved grammar
    static const char filename[] = "RecursionRemoved.txt";
    FILE *file = fopen ( filename, "r" );
    if ( file != NULL )
    {
        char line [ 128 ]; 
        while ( fgets ( line, sizeof line, file ) != NULL ) /* read a line */
        {
            //fputs ( line, stdout ); 
            if(strlen(line)==1)
            continue;
            strcpy(production[count],line);
            // printf("%s", buffer);
            count++;
        }
        fclose ( file );
    }
    else
    {
        perror ( filename ); 
    }
    
	char cur=' ';
	char t1=' ';
	char hash='#';
	int flag=1; // to check if new productions were made or not
	for(int i=0;i<count;i++)//checking the existing production one by one
	{
		cur=production[i][0];
		//printf("\nDealing with %s\n",production[i]);
		flag=0;
		t1=production[i][3]; 
		for(int j=i+1;j<count;j++)
		{
			
			if(cur==production[j][0])   //if left factoring is required
			{
				char temp1[100]="";     //for the new productions to be created
				char temp2[100]="";
				if(t1==production[j][3] && flag==0)  
				{
					strncat(temp1,&cur,1);
					strcat(temp1,"->");
					
					strncat(temp1,&t1,1);
					strcat(temp1,new_terminal);
					//new_terminal[0]=new_terminal[0]-1;
					//printf("\n%s",temp1);
					strcpy(new1[countnew1],temp1);          //Storing the new production formed
					countnew1++;
					strncat(temp2,new_terminal,1);
					strcat(temp2,"->");
					for(int z=4;z<strlen(production[i]);z++)
					{
						strncat(temp2,&production[i][z],1);
					}
					if(strlen(temp2)==4)
					{
						temp2[3]='#';
					}
					//printf("\n%s",temp2);
					strcpy(production[i],temp2);     //replacing the existing productionn with new production
					flag=1;
				}
				strcpy(temp2,"");
			
				if(t1==production[j][3] && flag==1)       //copying the remaining of the production
				{
					strncat(temp2,new_terminal,1);
					strcat(temp2,"->");
					for(int z=4;z<strlen(production[j]);z++)
					{
						strncat(temp2,&production[j][z],1);
					}
					if(strlen(temp2)==4)
					{
						temp2[3]='#';
					}
					//printf("\n%s",temp2);
					strcpy(production[j],temp2);
				}
			}
		}
		if(flag==1)         //decrement the new terminal to previous character if current one has been used
		{
			i=i-1;
			new_terminal[0]=new_terminal[0]-1;
		}
	}
	//writing the left factored grammar to txt file
	FILE *fptr2;

    fptr2 = fopen("LeftFactored.txt", "w");
	
	for(int i=0;i<countnew1;i++)
	{
		//printf("\n%s",new1[i]);
		fprintf(fptr2,"\n%s",new1[i]);
	}
	for(int j=0;j<count;j++)
	{
		//printf("\n%s",production[j]);
		fprintf(fptr2,"\n%s",production[j]);
	}
	fclose(fptr2);
}
void createFinalGrammar() //to create the final factored and Recursion Removed grmamar for task 3
{
	char production[100][SIZE];
    FILE *fptr;
    char filePath[100];

    char dataToAppend[BUFFER_SIZE];
    fptr = fopen("g2.txt", "w");
    fprintf(fptr,"\n");
    fclose(fptr);
    int count=0;
    static const char filename[] = "LeftFactored.txt";
    FILE *file = fopen ( filename, "r" );
    if ( file != NULL )
    {
        char line [ 128 ]; 
        while ( fgets ( line, sizeof line, file ) != NULL ) /* read a line */
        {
            //fputs ( line, stdout );
            if(strlen(line)==1)
            continue;
            strcpy(production[count],line);
            // printf("%s", buffer);
            count++;
        }
        fclose ( file );
    }
    else
    {
        perror ( filename );
    }
	
    
    FILE *fptr2;

    fptr2 = fopen("g2.txt", "w");
	printf("\nLeft Factored Grammer is:\n");
	for(int j=0;j<count;j++)
	{
		printf("%s",production[j]);
		fprintf(fptr2,"%s",production[j]);
	}
	fclose(fptr2); 
}

void find_first(vector< pair<char, string> > gram, 
	map< char, set<char> > &firsts, 
	char non_term) {

	// cout<<"Finding firsts of "<<non_term<<"\n";

	for(auto it = gram.begin(); it != gram.end(); ++it) {
		// Find productions of the non terminal
		if(it->first != non_term) {
			continue;
		}

		// cout<<"Processing production "<<it->first<<"->"<<it->second<<"\n";

		string rhs = it->second;
		// Loop till a non terminal or no epsilon variable found
		for(auto ch = rhs.begin(); ch != rhs.end(); ++ch) {
			// If first char in production a non term, add it to firsts list
			if(!isupper(*ch)) {
				firsts[non_term].insert(*ch);
				break;
			}
			else {
				// If char in prod is non terminal and whose firsts has no yet been found out
				// Find first for that non terminal
				if(firsts[*ch].empty()) {
					find_first(gram, firsts, *ch);
				}
				// If variable doesn't have epsilon, stop loop
				if(firsts[*ch].find('#') == firsts[*ch].end()) {
					firsts[non_term].insert(firsts[*ch].begin(), firsts[*ch].end());
					break;
				}

				set<char> firsts_copy(firsts[*ch].begin(), firsts[*ch].end());

				// Remove epsilon from firsts if not the last variable
				if(ch + 1 != rhs.end()) {
					firsts_copy.erase('#');
				}

				// Append firsts of that variable
				firsts[non_term].insert(firsts_copy.begin(), firsts_copy.end());
			}
		}
		
	}
}

void find_follow(vector< pair<char, string> > gram, 
	map< char, set<char> > &follows, 
	map< char, set<char> > firsts, 
	char non_term) {

	// cout<<"Finding follow of "<<non_term<<"\n";

	for(auto it = gram.begin(); it != gram.end(); ++it) {

		// finished is true when finding follow from this production is complete
		bool finished = true;
		auto ch = it->second.begin();

		// Skip variables till reqd non terminal
		for(;ch != it->second.end() ; ++ch) {
			if(*ch == non_term) {
				finished = false;
				break;
			}
		}
		++ch;

		for(;ch != it->second.end() && !finished; ++ch) {
			// If non terminal, just append to follow
			if(!isupper(*ch)) {
				follows[non_term].insert(*ch);
				finished = true;
				break;
			}

			set<char> firsts_copy(firsts[*ch]);
			// If char's firsts doesnt have epsilon follow search is over 
			if(firsts_copy.find('#') == firsts_copy.end()) {
				follows[non_term].insert(firsts_copy.begin(), firsts_copy.end());
				finished = true;
				break;
			}
			// Else next char has to be checked after appending firsts to follow
			firsts_copy.erase('#');
			follows[non_term].insert(firsts_copy.begin(), firsts_copy.end());

		}


		// If end of production, follow same as follow of variable
		if(ch == it->second.end() && !finished) {
			// Find follow if it doesn't have
			if(follows[it->first].empty()) {
				find_follow(gram, follows, firsts, it->first);
			}
			follows[non_term].insert(follows[it->first].begin(), follows[it->first].end());
		}

	}

}
void ParseTable()
{
    // Parsing the grammar file
	fstream grammar_file;
	grammar_file.open("g2.txt", ios::in);
	if(grammar_file.fail()) {
		cout<<"Error in opening grammar file\n";
	}

	cout<<"\nFinal Grammar with Numbered Productions: \n";
	vector< pair<char, string> > gram;
	int count = 0;
	while(!grammar_file.eof()) {
		char buffer[20];
		grammar_file.getline(buffer, 19);
        if(strlen(buffer)<2)
        {
            continue;
        }
		char lhs = buffer[0];
		string rhs = buffer+3;
		pair <char, string> prod (lhs, rhs);
		gram.push_back(prod);
		cout<<count++<<".  "<<gram.back().first<<" -> "<<gram.back().second<<"\n";
	}
	cout<<"\n";


	// Identify all non terminals
	set<char> non_terms;
	for(auto i = gram.begin(); i != gram.end(); ++i) {
		non_terms.insert(i->first);
	}
	cout<<"The non terminals in the grammar are: ";
	for(auto i = non_terms.begin(); i != non_terms.end(); ++i) {
		cout<<*i<<" ";
	}
	cout<<"\n";
	// Identify all terminals
	set<char> terms;
	for(auto i = gram.begin(); i != gram.end(); ++i) {
		for(auto ch = i->second.begin(); ch != i->second.end(); ++ch) {
			if(!isupper(*ch)) {
				terms.insert(*ch);
			}
		}
	}
	// Remove epsilon and add end character $
	terms.erase('#');
	terms.insert('$');
	cout<<"The terminals in the grammar are: ";
	for(auto i = terms.begin(); i != terms.end(); ++i) {
		cout<<*i<<" ";
	}
	cout<<"\n\n";


	// Start symbol is first non terminal production in grammar
	char start_sym = gram.begin()->first;


	map< char, set<char> > firsts;
	for(auto non_term = non_terms.begin(); non_term != non_terms.end(); ++non_term) {
		if(firsts[*non_term].empty()){
			find_first(gram, firsts, *non_term);
		}
	}

	cout<<"Firsts list:-> \n";
	for(auto it = firsts.begin(); it != firsts.end(); ++it) {
		cout<<it->first<<" : ";
		for(auto firsts_it = it->second.begin(); firsts_it != it->second.end(); ++firsts_it) {
			cout<<*firsts_it<<" ";
		}
		cout<<"\n";
	}
	cout<<"\n";


	map< char, set<char> > follows;
	// Find follow of start variable first
	char start_var = gram.begin()->first;
	follows[start_var].insert('$');
	find_follow(gram, follows, firsts, start_var);
	// Find follows for rest of variables
	for(auto it = non_terms.begin(); it != non_terms.end(); ++it) {
		if(follows[*it].empty()) {
			find_follow(gram, follows, firsts, *it);
		}
	}

	cout<<"Follows list:-> \n";
	for(auto it = follows.begin(); it != follows.end(); ++it) {
		cout<<it->first<<" : ";
		for(auto follows_it = it->second.begin(); follows_it != it->second.end(); ++follows_it) {
			cout<<*follows_it<<" ";
		}
		cout<<"\n";
	}
	cout<<"\n";

	int ppflag=1; //to check for collisions in parse table
	int parse_table[non_terms.size()][terms.size()];
	fill(&parse_table[0][0], &parse_table[0][0] + sizeof(parse_table)/sizeof(parse_table[0][0]), -1);
	for(auto prod = gram.begin(); prod != gram.end(); ++prod) {
		string rhs = prod->second;

		set<char> next_list;
		bool finished = false;
		for(auto ch = rhs.begin(); ch != rhs.end(); ++ch) {
			if(!isupper(*ch)) {
				if(*ch != '#') {
					next_list.insert(*ch);
					finished = true;
					break;
				}
				continue;
			}

			set<char> firsts_copy(firsts[*ch].begin(), firsts[*ch].end());
			if(firsts_copy.find('#') == firsts_copy.end()) {
				next_list.insert(firsts_copy.begin(), firsts_copy.end());
				finished = true;
				break;
			}
			firsts_copy.erase('#');
			next_list.insert(firsts_copy.begin(), firsts_copy.end());
		}
		// If the whole rhs can be skipped through epsilon or reaching the end
		// Add follow to next list
		if(!finished) {
			next_list.insert(follows[prod->first].begin(), follows[prod->first].end());
		}


		for(auto ch = next_list.begin(); ch != next_list.end(); ++ch) {
			int row = distance(non_terms.begin(), non_terms.find(prod->first));
			int col = distance(terms.begin(), terms.find(*ch));
			int prod_num = distance(gram.begin(), prod);
			
			if(parse_table[row][col] != -1) //if something is already in that cell, collision occurs
			{
				cout<<"Collision at ["<<row<<"]["<<col<<"] for production "<<prod_num<<"\n";
				ppflag=0;
				continue;
			}
			parse_table[row][col] = prod_num;
		}

	}
	// Print parse table
	cout<<"\nParsing Table:\n \n";
	cout<<"      ";
	int s=0;
	for(auto i = terms.begin(); i != terms.end(); ++i) {
		cout<<" | "<<*i<<"["<<s<<"]";
		s++;
	}
	cout<<" |  ";
	cout<<"\n";
	int gg=0;
	cout<<"-----------------------------------------------------------------------\n";
	for(auto row = non_terms.begin(); row != non_terms.end(); ++row) {
		cout<<*row<<"["<<gg<<"]"<<"   |  ";
		gg++;
		for(int col = 0; col < terms.size(); ++col) {
			int row_num = distance(non_terms.begin(), row);
			if(parse_table[row_num][col] == -1) {
				cout<<"-   |  ";
				continue;
			}
			cout<<parse_table[row_num][col]<<"   |  ";
		}
		cout<<"\n";
		cout<<"-----------------------------------------------------------------------\n";
	}
	cout<<"\n";
	//task 4
	if(ppflag==1)
	{
		cout<<"Grammar is LL(0) since no collision in parsing table\n";
	}
	else
	{
		cout<<"Grammar is not LL(0) since collision in parsing table\n";
	}
	input_string="ax(~bvc)";
	input_string.push_back('$');
	stack<char> st;
	st.push('$');
	st.push('S');

	// Check if input string is valid
	

	// cout<<"Processing input string\n";
	bool accepted = true;
	while(!st.empty() && !input_string.empty()) {
		// If stack top same as input string char remove it

		if(input_string[0] == st.top()) {
			st.pop();
			input_string.erase(0, 1);
		}
		else if(!isupper(st.top())) {
			cout<<"Unmatched terminal found\n";
			accepted = false;
			break;
		}
		else {
			char stack_top = st.top();
			int row = distance(non_terms.begin(), non_terms.find(stack_top));
			int col = distance(terms.begin(), terms.find(input_string[0]));
			int prod_num = parse_table[row][col];

			if(prod_num == -1) {
				cout<<"No production found in parse table\n";
				accepted = false;
				break;
			}

			st.pop();
			string rhs = gram[prod_num].second;
			if(rhs[0] == 'e') {
				continue;
			}
			for(auto ch = rhs.rbegin(); ch != rhs.rend(); ++ch) {
				st.push(*ch);
			}
		}
	}

	if(accepted) {
		cout<<"Input string is accepted\n";
	}
	else {
		cout<<"Input string is rejected\n";
	}

	return 0;

}
int main(int argc,char **argv) 
{
    //Adding a new line in input.txt file 
    FILE *fptra;
    fptra = fopen(argv[1], "a");
    fprintf(fptra,"\n");
    fclose(fptra);

    //Removing Comments from input.txt using lex and storing only the grammar in the grammar.txt file
    yyin=fopen(argv[1],"r");
    yyout=fopen("grammar.txt","w");
    fprintf(yyout,"\n"); 
    yylex();
    fprintf(yyout,"\n");
    fclose(yyin); 
    fclose(yyout);

    //removing left recusion
    indirectElimination();

    //left factoring 
    leftFactor();
    createFinalGrammar();

    //parse table generator
    ParseTable();
	
	return 0;
}
int yywrap()
{
    return(1);
}
